# Public subnet for Jenkins
resource "aws_subnet" "jenkins" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.jenkins_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-jenkins-subnet"
  }
}

# Route table for Jenkins subnet
resource "aws_route_table" "jenkins" {
  vpc_id = var.vpc_id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = data.aws_internet_gateway.existing.id
  }

  tags = {
    Name = "${var.cluster_name}-jenkins-rt"
  }
}

# Route table association
resource "aws_route_table_association" "jenkins" {
  subnet_id      = aws_subnet.jenkins.id
  route_table_id = aws_route_table.jenkins.id
}

# Security group for Jenkins
resource "aws_security_group" "jenkins" {
  name        = "${var.cluster_name}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-jenkins-sg"
  }
}

# IAM role for Jenkins to interact with AWS services
resource "aws_iam_role" "jenkins" {
  name = "${var.cluster_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Jenkins to push to ECR and access EKS
resource "aws_iam_role_policy" "jenkins" {
  name = "${var.cluster_name}-jenkins-policy"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.cluster_name}-jenkins-profile"
  role = aws_iam_role.jenkins.name
}

# Jenkins EC2 instance
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.jenkins_instance_type
  key_name               = var.jenkins_key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.jenkins.name
  subnet_id              = aws_subnet.jenkins.id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.jenkins_volume_size
    delete_on_termination = true
  }

  user_data = base64encode(file("${path.module}/jenkins-init.sh"))

  tags = {
    Name = "${var.cluster_name}-jenkins"
  }

  depends_on = [aws_subnet.jenkins]
}

# Elastic IP for Jenkins
resource "aws_eip" "jenkins" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"

  tags = {
    Name = "${var.cluster_name}-jenkins-eip"
  }

  depends_on = [aws_instance.jenkins]
}

# Route53 DNS record for Jenkins
resource "aws_route53_record" "jenkins" {
  zone_id = var.route53_zone_id
  name    = var.jenkins_dns_name
  type    = "A"
  ttl     = 300
  records = [aws_eip.jenkins.public_ip]
}

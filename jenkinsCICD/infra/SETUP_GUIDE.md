# Jenkins Infrastructure Setup Guide

## Prerequisites

Before deploying, gather the following information:

### 1. Get Your VPC ID

```bash
# List all VPCs
aws ec2 describe-vpcs --region ap-south-2

# Or get a specific VPC by name
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=my-vpc" \
  --region ap-south-2 \
  --query 'Vpcs[0].VpcId' \
  --output text
```

Example output: `vpc-0123456789abcdef0`

### 2. Get Your Availability Zone

```bash
# List availability zones in your region
aws ec2 describe-availability-zones \
  --region ap-south-2 \
  --query 'AvailabilityZones[*].ZoneName' \
  --output text
```

Example output: `ap-south-2a ap-south-2b`

### 3. Get Your EC2 Key Pair Name

```bash
# List your EC2 key pairs
aws ec2 describe-key-pairs --region ap-south-2

# Note the KeyName you want to use
```

Example output: `my-key-pair`

### 4. Get Your Route53 Zone ID

```bash
# List your hosted zones
aws route53 list-hosted-zones

# Find your domain and copy the Zone ID
```

Example output: `Z1234567890ABC`

### 5. Verify Subnet CIDR Doesn't Overlap

```bash
# Get existing subnets in your VPC
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-0123456789abcdef0" \
  --region ap-south-2 \
  --query 'Subnets[*].[CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

Make sure your `jenkins_subnet_cidr` (default: 10.0.100.0/24) doesn't overlap.

## Configuration Steps

### 1. Update terraform.tfvars

Edit `jenkinsCICD/infra/terraform.tfvars` with your values:

```hcl
# Your cluster name
cluster_name = "my-eks-cluster"

# Your existing VPC ID
vpc_id = "vpc-0123456789abcdef0"

# Your availability zone
availability_zone = "ap-south-2a"

# Jenkins subnet CIDR (must not overlap)
jenkins_subnet_cidr = "10.0.100.0/24"

# Your EC2 key pair
jenkins_key_pair_name = "my-key-pair"

# Restrict SSH to your IP (optional but recommended)
allowed_ssh_cidr = "203.0.113.0/32"

# Your Route53 zone ID
route53_zone_id = "Z1234567890ABC"

# Your domain name
jenkins_dns_name = "jenkins.example.com"
```

### 2. Validate Configuration

```bash
cd jenkinsCICD/infra
terraform validate
```

### 3. Review the Plan

```bash
terraform plan
```

This will show you:
- New subnet creation
- Internet gateway creation
- Route table creation
- Security group creation
- EC2 instance creation
- Elastic IP creation
- Route53 DNS record creation

### 4. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

### 5. Get Jenkins URL

```bash
# Get the DNS URL
terraform output jenkins_dns_url

# Get the Elastic IP URL
terraform output jenkins_public_url

# Get all outputs
terraform output
```

## What Gets Created

### Network Resources
- **Public Subnet**: New subnet in your existing VPC
- **Internet Gateway**: For public internet access
- **Route Table**: Routes traffic to internet gateway
- **Route Table Association**: Connects subnet to route table

### Security Resources
- **Security Group**: Allows SSH (22), Jenkins (8080), Agents (50000)

### Compute Resources
- **EC2 Instance**: t3.medium running Ubuntu 22.04
- **Elastic IP**: Static public IP
- **IAM Role**: Permissions for ECR and EKS access

### DNS Resources
- **Route53 Record**: Maps your domain to Elastic IP

## Accessing Jenkins

### Wait for Initialization

Jenkins takes 2-3 minutes to start. Check status:

```bash
# SSH to instance
ssh -i your-key.pem ubuntu@jenkins.example.com

# Check Jenkins status
sudo systemctl status jenkins

# View logs
sudo tail -f /var/log/jenkins/jenkins.log

# Get initial password (after Jenkins starts)
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Access Jenkins

1. Wait for DNS to propagate (5-30 minutes)
2. Open browser: `http://jenkins.example.com:8080`
3. Enter initial admin password
4. Complete setup wizard

## Troubleshooting

### DNS Not Resolving

```bash
# Check Route53 record
aws route53 list-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --query "ResourceRecordSets[?Name=='jenkins.example.com.']"

# Verify DNS
dig jenkins.example.com

# Wait for TTL (5 minutes) and try again
```

### Can't SSH to Instance

```bash
# Check security group
aws ec2 describe-security-groups \
  --group-ids sg-0123456789abcdef0 \
  --region ap-south-2

# Check instance status
aws ec2 describe-instances \
  --instance-ids i-0123456789abcdef0 \
  --region ap-south-2
```

### Subnet CIDR Overlap

If you get an error about CIDR overlap:
1. Check existing subnets: `aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxx"`
2. Update `jenkins_subnet_cidr` to a non-overlapping range
3. Run `terraform apply` again

### Terraform Errors

```bash
# Validate configuration
terraform validate

# Check variable values
terraform plan -var-file=terraform.tfvars

# Refresh state
terraform refresh
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

This removes:
- Subnet
- Internet Gateway
- Route table
- Security group
- EC2 instance
- Elastic IP
- Route53 DNS record
- IAM role and policies

## Next Steps

1. ✅ Gather prerequisites
2. ✅ Update terraform.tfvars
3. ✅ Run terraform validate
4. ✅ Run terraform plan
5. ✅ Run terraform apply
6. ✅ Wait for Jenkins to start
7. ✅ Access Jenkins
8. ✅ Complete Jenkins setup (see JENKINS_CONFIGURATION.md)

## Quick Reference

```bash
# Get VPC ID
aws ec2 describe-vpcs --region ap-south-2

# Get AZs
aws ec2 describe-availability-zones --region ap-south-2

# Get key pairs
aws ec2 describe-key-pairs --region ap-south-2

# Get Route53 zones
aws route53 list-hosted-zones

# Validate
terraform validate

# Plan
terraform plan

# Apply
terraform apply

# Get outputs
terraform output

# Destroy
terraform destroy
```

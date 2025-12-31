variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID to use for Jenkins"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the public subnet"
  type        = string
}

variable "jenkins_subnet_cidr" {
  description = "CIDR block for Jenkins public subnet"
  type        = string
  default     = "10.0.100.0/24"
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.medium"
}

variable "jenkins_volume_size" {
  description = "EBS volume size for Jenkins in GB"
  type        = number
  default     = 50
}

variable "jenkins_key_pair_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "jenkins_dns_name" {
  description = "DNS name for Jenkins (e.g., jenkins.example.com)"
  type        = string
}

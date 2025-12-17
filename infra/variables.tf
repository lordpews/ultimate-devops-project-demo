variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "node_groups" {
  description = "EKS node group configuration"
  type = map(object({
    capacity_type = string
    instance_type = list(string)
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
}

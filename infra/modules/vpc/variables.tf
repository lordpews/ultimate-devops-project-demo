variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR"
  type        = string
}
variable "region" {
  default     = "ap-south-2"
  description = "region for vpc"
  type        = string
}

variable "public_subnet_cidr" {
  description = "public subnet cidr"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "private subnet cidr"
  type        = list(string)
}

variable "availability_zones" {
  description = "availability zone"
  type        = list(string)
}
variable "cluster_name" {
  type        = string
  description = "name of the cluster"
}
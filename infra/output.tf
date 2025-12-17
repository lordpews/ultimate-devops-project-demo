output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint"
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.name
}

output "vpc_details" {
  description = "VPC details"
  value       = module.vpc.vpc_details
}
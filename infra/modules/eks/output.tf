output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "name" {
  value = aws_eks_cluster.cluster.name
}

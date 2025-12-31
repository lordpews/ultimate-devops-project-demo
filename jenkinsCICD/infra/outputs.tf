output "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = aws_instance.jenkins.id
}

output "jenkins_private_ip" {
  description = "Jenkins private IP address"
  value       = aws_instance.jenkins.private_ip
}

output "jenkins_public_ip" {
  description = "Jenkins public IP address (Elastic IP)"
  value       = aws_eip.jenkins.public_ip
}

output "jenkins_public_url" {
  description = "Jenkins public URL using Elastic IP"
  value       = "http://${aws_eip.jenkins.public_ip}:8080"
}

output "jenkins_dns_url" {
  description = "Jenkins DNS URL"
  value       = "http://${var.jenkins_dns_name}:8080"
}

output "jenkins_dns_name" {
  description = "Jenkins DNS name"
  value       = var.jenkins_dns_name
}

output "jenkins_security_group_id" {
  description = "Jenkins security group ID"
  value       = aws_security_group.jenkins.id
}

output "jenkins_iam_role_name" {
  description = "Jenkins IAM role name"
  value       = aws_iam_role.jenkins.name
}

output "jenkins_iam_role_arn" {
  description = "Jenkins IAM role ARN"
  value       = aws_iam_role.jenkins.arn
}

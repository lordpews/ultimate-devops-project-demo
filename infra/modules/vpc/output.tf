output "vpc_details" {
  description = "vpc details"
  value       = [aws_vpc.main.id, aws_vpc.main.region]
}

output "public_subnet_details" {
  description = "public subnet details"
  value       = [aws_subnet.public[*].id, aws_subnet.public[*].cidr_block]
}

output "private_subnet_details" {
  description = "public subnet details"
  value       = [aws_subnet.private[*].id, aws_subnet.private[*].cidr_block]
}
output "internet_gateway_details" {
  description = "internet gateway details"
  value       = [aws_internet_gateway.main.id]
}

output "nat_gateway_details" {
  description = "nat gateway details"
  value       = [aws_nat_gateway.main[*].id]
}
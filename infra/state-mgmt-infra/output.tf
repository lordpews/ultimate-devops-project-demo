output "bucket_name" {
  description = "terraform state file s3 bucket"
  value       = aws_s3_bucket.terraform_state_s3.id
}

output "dynamodb_name" {
  description = "terraform state file dynamodb"
  value       = aws_dynamodb_table.terraform_state_lock_dynamodb.id

}

output "dynamodb_arn" {
  description = "terraform state file dynamodb arn"
  value       = aws_dynamodb_table.terraform_state_lock_dynamodb.arn

}
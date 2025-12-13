resource "aws_s3_bucket" "terraform_state_s3" {
  bucket = "terraform-state-bucket-ap-south-2"
  lifecycle {
    prevent_destroy = false
  }

}

resource "aws_dynamodb_table" "terraform_state_lock_dynamodb" {
  name         = "terraform_state_lock_db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockId"

  attribute {
    name = "LockId"
    type = "S"
  }
}
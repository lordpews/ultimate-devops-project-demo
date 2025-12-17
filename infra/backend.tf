terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-ap-south-2"
    key            = "opentelemetry/terraform.tfstate"
    region         = "ap-south-2"
    dynamodb_table = "terraform_state_lock_db"
    encrypt        = false
  }
}
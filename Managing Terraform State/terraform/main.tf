terraform {
  backend "s3" {
    bucket         = "my-unique-project-name-2026-v1"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-remote-state-s3-store"
    key            = "aws/us-east-2/dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "s3-state-lock"
  }
}

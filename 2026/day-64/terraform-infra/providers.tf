terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraweek-state-aliya"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

# resource "aws_s3_bucket" "imported" {
#   bucket = "terraweek-import-test-aliya"
# }

resource "aws_s3_bucket" "logs_bucket" {
  bucket = "terraweek-import-test-aliya"
}

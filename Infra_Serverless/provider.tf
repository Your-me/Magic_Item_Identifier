terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" # Or your desired version
    }
  }
  required_version = ">=1.0"
  backend "s3" {
    bucket = var.bucket_name
    key    = "aws/magic_item_lambda/terraform.tfstate"
    region = "eu-west-2"      
  }
}

provider "aws" {
  region = "eu-west-2"
}
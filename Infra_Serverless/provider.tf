terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" # Or your desired version
    }
  }
  #required_version = ">=1.0"
  #backend "s3" {
  #  bucket = var.bucket_name
  #  key    = "aws/ec2-deploy/terraform.tfstate"
  #  region = "us-east-1"      
  #}
}

provider "aws" {
  region = "eu-west-2"
}
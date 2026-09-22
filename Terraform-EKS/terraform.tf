terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.37.0, < 7.0.0"
    }
  }

  backend "s3" {
    bucket       = "<YOUR_TERRAFORM_BACKEND_BUCKET>"
    key          = "eks/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "foo.terraform.backend"
    key     = "internal/aws-foo-vpn.tfstate"
    region  = "us-east-1"
    profile = "foobar"
  }

  required_providers {
    aws = "~> 2.0"
  }

  required_version = "~> 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.aws_region
  profile = var.aws_profile
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_availability_zones" "available" {
}

data "aws_caller_identity" "current" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
}





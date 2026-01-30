# Provider & Version
# https://registry.terraform.io/providers/hashicorp/aws/6.17.0/docs

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias = "use1"
  region = "us-east-1"
}

provider "aws" {
  alias = "sa_east_1"
  region = "sa-east-1"
}

provider "aws" {
  alias = "ap-northeast-1"
  region = "ap-northeast-1"
}

provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"   # or "~> 6.0" if you want latest
    }
  }
}
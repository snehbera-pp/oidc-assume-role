terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      CreatedBy = "sneh_bera"
    }
  }
}

provider "github" {
  owner = "snehbera-pp"
  # token comes from env var: export GITHUB_TOKEN=<your PAT>
}
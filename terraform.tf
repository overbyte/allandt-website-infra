terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "allandt"
    workspaces {
      prefix = "website-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region      = "eu-west-2"
}

locals {
  project        = "allandtwebsite"
  namespace      = "${var.workspace}_${local.project}"
  namespace_dash = "${var.workspace}-${local.project}"
  tags = map(
    "workspace", var.workspace,
    "project", local.project
  )
}

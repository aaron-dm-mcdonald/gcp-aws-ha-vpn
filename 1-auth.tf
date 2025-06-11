terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  backend "s3" {
    bucket  = "terraform-state-aaronmcd" # Name of the S3 bucket
    key     = "multicloud/state.tfstate" # The name of the state file in the bucket
    region  = "us-east-2"
    encrypt = true # Enable server-side encryption (optional but recommended)
  }
}

provider "aws" {
  region  = var.aws_config.region
  profile = "default"
}

provider "google" {
  project     = var.gcp_config.project
  region      = var.gcp_config.region
  credentials = "key-061025.json"
}
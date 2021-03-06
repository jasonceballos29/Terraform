# AWS ECS Cluster with Docker built with Terraform
# Authored by Jason Ceballos
# 06/25/2022

# Define the provider
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "docker" {}

provider "aws" {
  region = var.region
  # If you are running from AWS EC2 Linux instance, please use the credentials section below:
  # shared_credentials_file = "$HOME/.aws/credentials"
  # profile = "default"

}

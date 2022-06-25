# AWS ECS Cluster with Docker built with Terraform
# Authored by Jason Ceballos
# 06/25/2022

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
# VPC CIDR block
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  tags = {
        Name = "project_vpc"
    }
}

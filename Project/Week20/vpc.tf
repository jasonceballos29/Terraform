# AWS ECS Cluster with Docker built with Terraform
# Authored by Jason Ceballos
# 06/25/2022

resource "aws_vpc" "ecs_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "VPC for ECS Cluster Project"
  }
}
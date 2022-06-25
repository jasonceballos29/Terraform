# AWS ECS Cluster with Docker built with Terraform
# Authored by Jason Ceballos
# 06/25/2022

# Create private subnets, each in a different AZ for redundancy
resource "aws_subnet" "priv_subnet1" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet 1"
  }
}


resource "aws_subnet" "priv_subnet2" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet 2"
  }
}
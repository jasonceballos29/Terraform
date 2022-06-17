variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]
}

variable "instances_per_subnet" {
  description = "Number of EC2 instances per public subnet"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t2.micro"
}

# Warning: The following is only for demonstration purposes. DO NOT ADD sensitive values like
# usernames and passwords into source control.

variable "db_username" {
  description = "Database administrator username."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database administrator password."
  type        = string
  default     = "followthewhiterabbit"
}
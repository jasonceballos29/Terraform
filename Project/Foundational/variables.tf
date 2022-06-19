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
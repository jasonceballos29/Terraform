# Two Tiered Architecture with Terraform
# Authored by Jason Ceballos
# 06/18/2022
# Define the provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.16.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}
# Create a custom VPC for the project
resource "aws_vpc" "project_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "project_vpc"
    }
}
# Create the web server public subnets
resource "aws_subnet" "pubsub_1" {
    tags = {
        Name = "PubSub_1"
    }
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
    depends_on = [
      aws_vpc.project_vpc
    ]
    }
resource "aws_subnet" "pubsub_2" {
    tags = {
        Name = "PubSub_2"
    }
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1b"
    depends_on = [
      aws_vpc.project_vpc
    ]
    }
# Create the DB Server private subnets
resource "aws_subnet" "projectdb_subnet1" {
    tags = {
        Name = "DBSubnet" 
    }
    vpc_id = aws_subnet.pubsub_1.id
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = false
    availability_zone = "us-east-1b"
    depends_on = [
      aws_vpc.project_vpc
    ]
}
resource "aws_subnet" "projectdb_subnet2" {
    tags = {
        Name = "DBSubnet2" 
    }
    vpc_id = aws_subnet.pubsub_1.id
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = false
    availability_zone = "us-east-1a"
    depends_on = [
      aws_vpc.project_vpc
    ]
}
# Create a private subnet group for the DB Servers
resource "aws_db_subnet_group" "db-subnet" {
    name = "DB subnet group"
    subnet_ids = ["${aws_subnet.projectdb_subnet1.id}", "${aws_subnet.projectdb_subnet2.id}"]
}      
# Define routing table for Public Subnets
resource "aws_route_table" "project_routingtable" {
    vpc_id = aws.aws_vpc.project_vpc

    route {
        cidr_block = "10.0.1.0/24"
        gateway_id = aws_internet_gateway.project_IG.id
    }
    route {
        cidr_block = "10.0.2.0/24"
        gateway_id = aws_internet_gateway.project_IG.id
  }
    tags = {
        Name = "project_routingtable"
    }
}

# Associate routing table with VPC
resource "aws_route_table_association" "AppRouteAssociation" {
    subnet_id = aws_vpc.project_vpc.id
    route_table_id = aws_routing_table.project_routingtable.id
}
# Create Internet Gateway
resource "aws_internet_gateway" "project_IG" {
    tags = {
        Name = "Project_IG"
    }
    vpc_id = aws_vpc.project_vpc.id
    depends_on = [
      aws_vpc.project_vpc
    ]
}
# Add default route in routing table to point to Internet Gateway
resource "aws_route" "project_route" {
    route_table_id = aws_route_table_association.project_routingtable.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_IG.id  
}
# Create security group for Web Servers
resource "aws_security_group" "AppSG" {
    name = "AppSG"
    description = "Allow weh inbound traffic"
    vpc_id = aws_vpc.project_vpc.id
    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 80
      protocol = "tcp"
      to_port = 80
    }
    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 22
      protocol = "tcp"
      to_port = 22
    }
    egress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 0
      protocol = "-1"
      to_port = 0
    }
}
# Create security group for DB Servers
resource "aws_security_group" "DB_SG" {
    name = "DB_SG"
    description = "Allow weh inbound traffic"
    vpc_id = aws_vpc.project_vpc.id
    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 3306
      protocol = "tcp"
      to_port = 3306
      security_groups = [ aws_security_group.AppSG.id ]
    }
    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 22
      protocol = "tcp"
      to_port = 22
      security_groups = [ aws_security_group.AppSG.id ]
    }
    egress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 0
      protocol = "-1"
      to_port = 0
    }
}
# Create a private key which will be used to login to the App Servers
resource "tls_private_key" "WebKey" {
    algorithm = "RSA"
}
# Save public key attributes from the generated key
resource "aws_key_pair" "App-Instance-Key" {
    key_name = "WebKey"
    public_key = tls_private_key.WebKey.public_key_openssh
}
# Save the key to your local system
resource "local_file" "WebKey" {
    content = tls_private_key.WebKey.private_key_pem
    filename = "WebKey.pem"
}

### Creating ELB
resource "aws_elb" "example" {
    tags = {
        Name = "project-terraform-elb"
    }
    name = "project-terraform-elb"
    internal = false
    availability_zones = ["us-east-1a", "us-east-1b"]
    listener {
        instance_port     = "80"
        instance_protocol = "HTTP"
        lb_port           = "80"
        lb_protocol       = "HTTP"
    }
    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        interval = 30
        target = "HTTP:8080/"
    }
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

}

# Create the web server instances using AMIs from us-east-1 region. This is region specific
resource "aws_instance" "Web1" {
    ami = "ami-0cff7528ff583bf9a"
    instance_type = "t2-micro"
    tags = {
      "Name" = "WebServer1"
    }
    count = 1
    subnet_id = aws_subnet.pubsub_1.id
    key_name = "WebKey"
    security_groups = [ aws_security_group.AppSG.id ]  
}
resource "aws_instance" "Web2" {
    ami = "ami-0cff7528ff583bf9a"
    instance_type = "t2-micro"
    tags = {
      "Name" = "WebServer2"
    }
    count = 1
    subnet_id = aws_subnet.pubsub_1.id
    key_name = "WebKey"
    security_groups = [ aws_security_group.AppSG.id ]  
}
# Create the RDS DB Server and attach it to the DB_SG security group. Deployed to private subnet2 in this example.
# Also configured credentials in variable file and specified instance details.
resource "aws_db_instance" "project_database" {
    tags = {
        "Name" = "DBServer1"
        }
        count = 1
        Name = "DBServer1"
        allocated_storage = 5
        engine  = "mysql"
        instance_class = "db.t2.micro"
        username = var.db_username
        password = var.db_password
        db_subnet_group_name = "${aws_db_subnet_group.db-subnet.name}"
        subnet_id = aws_subnet.projectdb_subnet2.id
        key_name = "WebKey"
        security_groups = [ aws_security_group.DB_SG.id ]
        publicly_accessible = false
        skip_final_snapshot = true
}
# Need this section to copy the private key to the DB Server for remote SSH access since they are not accessible from the web
# Copies the private key to each EC2 instance under the home directory on the DB Server
resource "null_resource" "Copy_Key_EC2" {
    depends_on = [
      aws_instance.Web1
    ]
    provisioner "local-exec" {
        command = "scp -o StrictHostKeyChecking=no -i WebKey.pem WebKey.pem ec2-user@${aws_instance.Web1[0].public_ip}:/home/ec2-user"
    }
  
}

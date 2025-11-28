terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.92"
        }
    }
    required_version = ">= 1.2"
}

provider "aws" {
    region = var.aws_region
    profile = var.myprofile
}

resource "aws_vpc" "demo-vpc-tf" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "demo-vpc-tf"
    }
}

resource "aws_subnet" "demo-subnet-tf" {
    vpc_id            = aws_vpc.demo-vpc-tf.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = true
    tags = {
        Name = "demo-subnet-tf"
    }
}

resource "aws_internet_gateway" "demo-igw-tf" {
    vpc_id = aws_vpc.demo-vpc-tf.id
    tags = {
        Name = "demo-igw-tf"
    }
}

resource "aws_route_table" "demo-rt-tf" {
    vpc_id = aws_vpc.demo-vpc-tf.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo-igw-tf.id
    }
    tags = {
        Name = "demo-rt-tf"
    }
}

resource "aws_route_table_association" "demo-rt-assoc-tf" {
    subnet_id      = aws_subnet.demo-subnet-tf.id
    route_table_id = aws_route_table.demo-rt-tf.id
}

resource "aws_security_group" "demo-sg-tf" {
    name       = "demo-sg-tf"
    description = "Demo SG for Terraform"
    vpc_id      = aws_vpc.demo-vpc-tf.id
}

resource "aws_vpc_security_group_ingress_rule" "SSH" {
    security_group_id = aws_security_group.demo-sg-tf.id
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "ICMP" {
    security_group_id = aws_security_group.demo-sg-tf.id
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = -1
    ip_protocol = "icmp"
    to_port     = -1
}

resource "aws_vpc_security_group_ingress_rule" "Custom_Web" {
    security_group_id = aws_security_group.demo-sg-tf.id
    cidr_ipv4   = "0.0.0.0/0"
    from_port   = 5000
    ip_protocol = "tcp"
    to_port     = 5000
}

resource "aws_vpc_security_group_egress_rule" "wildcard_egress" {
    security_group_id = aws_security_group.demo-sg-tf.id
    cidr_ipv4   = "0.0.0.0/0"
    ip_protocol = "-1"
}

resource "aws_instance" "demo-ec2-tf" {
    ami                    = var.ami_id
    instance_type          = "t3.micro"
    subnet_id              = aws_subnet.demo-subnet-tf.id
    vpc_security_group_ids = [aws_security_group.demo-sg-tf.id]
    key_name               = "ec2-key-tf"
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.demo-ec2-instance-profile-tf.name
    tags = {
        Name = "demo-ec2-tf"
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo amazon-linux-extras install docker
                sudo yum install -y docker
                sudo service docker start
                sudo usermod -a -G docker ec2-user
                EOF 
}

resource "aws_ecr_repository" "demo-ecr-tf" {
    name = "demo-ecr-tf"
    image_tag_mutability = "IMMUTABLE"
    image_scanning_configuration {
      scan_on_push = true
    }
}


# Create IAM role and instance profile for EC2 to access ECR

data "aws_iam_policy_document" "ec2-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "demo-ec2-role-tf" {
  name               = "demo-ec2-ecr-role-tf"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume-role.json
}

resource "aws_iam_role_policy_attachment" "demo-ecr-readonly-tf" {
  role       = aws_iam_role.demo-ec2-role-tf.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "demo-ec2-instance-profile-tf" {
  name = "demo-ec2-instance-profile-tf"
  role = aws_iam_role.demo-ec2-role-tf.name
}
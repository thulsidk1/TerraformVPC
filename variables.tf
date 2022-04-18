# Variables

variable "region" {
  default = "us-east-2"
}
variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "private_cidr"{
type = list
default = ["10.0.2.0/24" , "10.0.3.0/24"]
description = "cidr for subnets"
}

variable "public_cidr"{
type = list
default = ["10.0.0.0/24" , "10.0.1.0/24"]
description = "cidr for subnets"
}

variable "availability_zone" {
  description = "availability zone to create subnet"
  default     = "us-east-2a"
}

variable "availability_zone1" {
  description = "availability zone to create subnet1"
  default     = "us-east-2b"
}

data "aws_ami" "my_awslinux" {
owners = ["137112412989"] # AWS
most_recent = true

  filter {
      name   = "name"
      values = ["*-2.0.20180810-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

variable "instance_type" {
  description = "type for aws EC2 instance"
  default     = "t2.micro"
}
variable "environment_tag" {
  description = "Environment tag"
  default     = "Production"
}

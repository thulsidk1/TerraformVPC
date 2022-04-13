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


variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default     = "10.0.0.0/24"
}
variable "cidr_subnet1" {
  description = "CIDR block for the subnet1"
  default     = "10.0.1.0/24"
}

variable "cidr_subnet2" {
  description = "CIDR block for the subnet1"
  default     = "10.22.8.0/24"
}

variable "cidr_subnet3" {
  description = "CIDR block for the subnet1"
  default     = "10.22.9.0/24"
}
variable "availability_zone" {
  description = "availability zone to create subnet"
  default     = "us-east-2a"
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
variable "vpc_tag" {
  description = "VPC tag"
  default     = "VPC"
}
variable "igw_tag" {
  description = "Internetgateway tag"
  default     = "IGW"
}
variable "nat_tag" {
  description = "Network Address Translation Gateway tag"
  default     = "NAT"
}
variable "publicsubnet_tag" {
  description = "Public Subnet tag"
  default     = "PubliCSubnet"
}
variable "privatesubnet_tag" {
  description = "Private Subnet tag"
  default     = "PrivateSubnet"
}
variable "publicroutetable_tag" {
  description = "Public Route Table tag"
  default     = "PublicRouteTable"
}
variable "privateroutetable_tag" {
  description = "Private Route Table tag"
  default     = "PrivateRouteTable"
}
variable "securitygroup_tag" {
  description = "Security Group tag"
  default     = "SecurityGroup"
}
variable "awsinstance_tag" {
  description = "aws instance  tag"
  default     = "awspublicinstance"
}
variable "awsinstance1_tag" {
  description = "aws instance  tag1"
  default     = "awsprivateinstance"
}

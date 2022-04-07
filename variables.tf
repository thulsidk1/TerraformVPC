variable "region" {
  default = "us-east-2"
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}

variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default     = "10.1.0.0/24"
}

variable "cidr_subnet2" {
  description = "CIDR block for the subnet1"
  default     = "10.2.1.0/1"
}

variable "cidr_subnet3" {
  description = "CIDR block for the subnet1"
  default     = "10.3.1.0/1"
}

variable "availability_zone" {
  description = "availability zone to create subnet"
  default     = "us-east-2a"
}

data "aws_ami" "my_awslinux" {
  owners      = ["137112412989"] # AWS
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

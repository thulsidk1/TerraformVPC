provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_tag
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_tag
  }
}

resource "aws_eip" "ip" {
  vpc = true
}

resource "aws_nat_gateway" "natgw1" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.subnet_public.id

  tags = {
    Name = var.nat_tag
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_subnet
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone

  tags = {
    Name = var.publicsubnet_tag
  }
}

resource "aws_subnet" "subnet_private1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_subnet1
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone

  tags = {
    Name = var.privatesubnet_tag
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.publicroutetable_tag
  }
}

resource "aws_route_table" "rtb_private1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw1.id
  }

  tags = {
    Name = var.privateroutetable_tag
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table_association" "rta_subnet_private1" {
  subnet_id      = aws_subnet.subnet_private1.id
  route_table_id = aws_route_table.rtb_private1.id
}

resource "aws_security_group" "sg_22" {
  name   = "sg_22"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_vpc, "49.37.173.251/32", "98.180.121.31/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.securitygroup_tag
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.testInstance.id
  allocation_id = aws_eip.example.id
}


resource "aws_instance" "testInstance" {
  ami                    = data.aws_ami.my_awslinux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_public.id
  key_name               = "lakshminarsimha"
  vpc_security_group_ids = [aws_security_group.sg_22.id]

  tags = {
    Name = var.awsinstance_tag
  }
}

resource "aws_eip" "example" {
  vpc = true
}

resource "aws_instance" "testInstance1" {
  ami                    = data.aws_ami.my_awslinux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_private1.id
  key_name               = "lakshminarsimha"
  vpc_security_group_ids = [aws_security_group.sg_22.id]

  tags = {
    Name = var.awsinstance1_tag
  }
}

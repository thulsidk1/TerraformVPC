provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment_tag}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment_tag}-igw"
  }
}

resource "aws_eip" "ip" {
  count                  = "${length(var.private_cidr)}"
  vpc = true

  tags = {
    Name = "${var.environment_tag}-eip-private${count.index}"

  }
}

resource "aws_eip" "ip1" {
  vpc = true

  tags = {
    Name = "${var.environment_tag}-eip-public"

  }
}

resource "aws_nat_gateway" "natgw1" {
  count          = "${length(var.public_cidr)}"
  allocation_id  = aws_eip.ip.id
  subnet_id      = element(aws_subnet.subnet_public.*.id , count.index)

  tags = {
    Name = "${var.environment_tag}-natgw${count.index}"
  }
}

resource "aws_subnet" "subnet_public" {
  count                    = "${length(var.public_cidr)}"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_cidr , count.index)
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone

  tags = {
    Name = "${var.environment_tag}-subnet_public${count.index}"
  }
}



resource "aws_subnet" "subnet_private1" {
  count                   = "${length(var.private_cidr)}"
  vpc_id                  =  aws_vpc.vpc.id
  cidr_block              =  element(var.private_cidr , count.index)
  availability_zone       =  var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment_tag}-subnet_private1${count.index}"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment_tag}-rtb_public"
  }
}

resource "aws_route_table" "rtb_private1" {
  count          = "${length(var.public_cidr)}"
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.natgw1.*.id , count.index)
  }

  tags = {
    Name = "${var.environment_tag}-rtb_private1${count.index}"
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  count          = "${length(var.public_cidr)}"
  subnet_id      = element(aws_subnet.subnet_public.*.id , count.index)
  route_table_id = element(aws_route_table.rtb_public.*.id , count.index)
}

resource "aws_route_table_association" "rta_subnet_private1" {
  count          = "${length(var.private_cidr)}"
  subnet_id      = element(aws_subnet.subnet_private1.*.id , count.index)
  route_table_id = element(aws_route_table.rtb_private1.*.id , count.index)
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
    Name = "${var.environment_tag}-security-group"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.testInstance.id
  allocation_id = aws_eip.ip1.id
}


resource "aws_instance" "testInstance" {
  ami                    = data.aws_ami.my_awslinux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_public[0].id
  key_name               = "lakshminarsimha"
  vpc_security_group_ids = [aws_security_group.sg_22.id]

  tags = {
    Name = "${var.environment_tag}-testInstance"
  }
}



resource "aws_instance" "testInstance1" {
  ami                    = data.aws_ami.my_awslinux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_private1[0].id
  key_name               = "lakshminarsimha"
  vpc_security_group_ids = [aws_security_group.sg_22.id]

  tags = {
    Name = "${var.environment_tag}-testInstance1"
  }
}

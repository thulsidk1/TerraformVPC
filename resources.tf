#providers
provider "aws" {
	shared_credentials_file  = "C:\\Users\\ThulsiDossK\\.aws\\credentials"
	region = "${var.region}"
}

#resources
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_vpc}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_eip" "ip" {
 vpc =  true
}
resource "aws_nat_gateway" "natgw1" {
 allocation_id="${aws_eip.ip.id}"
  subnet_id = "${aws_subnet.subnet_public.id}"
  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.cidr_subnet}"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.availability_zone}"
  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_subnet" "subnet_private1" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.cidr_subnet1}"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.availability_zone}"
  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_route_table" "rtb_private1" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_nat_gateway.natgw1.id}"
  }

  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = "${aws_subnet.subnet_public.id}"
  route_table_id = "${aws_route_table.rtb_public.id}"
}

resource "aws_route_table_association" "rta_subnet_private1" {
  subnet_id      = "${aws_subnet.subnet_private1.id}"
  route_table_id = "${aws_route_table.rtb_private1.id}"
}

resource "aws_security_group" "sg_22" {
  name = "sg_22"
  vpc_id = "${aws_vpc.vpc.id}"

  # SSH access from the VPC
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_security_group" "sg_221" {
  name = "sg_221"
  vpc_id = "${aws_vpc.vpc.id}"

  # SSH access from the VPC
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

	egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_network_acl" "My_VPC_Security_ACL" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = ["${aws_subnet.subnet_private1.id}"]
# allow ingress port 1024 to 65535
  ingress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # allow ingress port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "${var.cidr_subnet}"
    from_port  = 80
    to_port    = 80
  }



  # allow egress port 80
  egress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # allow egress port 80
  egress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "${var.cidr_subnet}"
    from_port  = 80
    to_port    = 80
  }

  # allow egress ephemeral ports
    egress {
      protocol   = "tcp"
      rule_no    = 6
      action     = "allow"
      cidr_block = "${var.cidr_subnet}"
      from_port  = 443
      to_port    = 443
  }
tags = {
    Name = "My VPC ACL"
}
}

resource "aws_network_acl" "My_VPC_Security_ACL1" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = ["${aws_subnet.subnet_public.id}"]
# allow ingress port 1024 to 65535
  ingress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "${var.cidr_subnet1}"
    from_port  = 443
    to_port    = 443
  }

  # allow ingress port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "${var.cidr_subnet1}"
    from_port  = 80
    to_port    = 80
  }
	# allow ingress port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }




  # allow egress port 80
  egress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # allow egress port 80
  egress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 6
    action     = "allow"
    cidr_block = "${var.cidr_subnet1}"
    from_port  = 1024
    to_port    = 65535
  }


tags = {
    Name = "My VPC ACL1"
}
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}





resource "aws_instance" "testInstance" {
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.subnet_public.id}"
	key_name = "lakshminarsimha"
  vpc_security_group_ids = [aws_security_group.sg_22.id]
  tags = {
		"Environment" = "${var.environment_tag}"
	}
}

resource "aws_instance" "testInstance1" {
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.subnet_private1.id}"
	key_name = "lakshminarsimha"
  vpc_security_group_ids = [aws_security_group.sg_221.id]
  tags = {
		"Environment" = "${var.environment_tag}"
	}
}

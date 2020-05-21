variable "config" {
  type = "map"
}

# check for presence of all config variables
locals {
  region = "${var.config["region"]}"
  account_id = "${var.config["account_id"]}"
  env = "${var.config["env"]}"
  domain = "${local.env}-${var.config["domain"]}"
}

provider "aws" {
  region = "${var.config["region"]}"
  profile = "${var.config["profile"]}"
}

##############################################################################
# VPC
##############################################################################


output domain {
  value = "${var.config["domain"]}"
}
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.config["vpc.cidr_block"]}"

  tags = {
    Name                                  = "${local.domain}"
  }
}

resource "aws_internet_gateway" "i_gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    environment                           = "global"
    Name                                  = "${local.domain}"
  }
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name         = "$${local.domain}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dhcp_options_assc" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp_options.id}"
}

##############################################################################
# Public Subnets
##############################################################################

resource "aws_route_table" "rt_public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.i_gw.id}"
  }

  tags = {
    Name                                  = "${local.domain}"
    environment                           = "global"
  }
}

resource "aws_subnet" "subnet_public_b" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.config["subnet.subnet_public_b.cidr_block"]}"
  availability_zone       = "${local.region}b"
  map_public_ip_on_launch = true

  tags {
    Name   = "${local.domain}-subnet_public_b"
    Access = "public"
  }
}

resource "aws_subnet" "subnet_public_c" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.config["subnet.subnet_public_c.cidr_block"]}"
  availability_zone       = "${local.region}c"
  map_public_ip_on_launch = true

  tags {
    Name   = "${local.domain}-subnet_public_c"
    Access = "public"
  }
}

resource "aws_route_table_association" "rt_assc_public_b" {
  subnet_id      = "${aws_subnet.subnet_public_b.id}"
  route_table_id = "${aws_route_table.rt_public.id}"
}

resource "aws_route_table_association" "rt_assc_public_c" {
  subnet_id      = "${aws_subnet.subnet_public_c.id}"
  route_table_id = "${aws_route_table.rt_public.id}"
}

##############################################################################
# NAT Gateways for routing
##############################################################################

resource "aws_nat_gateway" "nat_gw_b" {
  allocation_id = "${aws_eip.nat_b.id}"
  subnet_id     = "${aws_subnet.subnet_public_b.id}"
  depends_on    = ["aws_internet_gateway.i_gw"]
}

resource "aws_eip" "nat_b" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw_c" {
  allocation_id = "${aws_eip.nat_c.id}"
  subnet_id     = "${aws_subnet.subnet_public_c.id}"
  depends_on    = ["aws_internet_gateway.i_gw"]
}

resource "aws_eip" "nat_c" {
  vpc = true
}

##############################################################################
# Private subnets
##############################################################################

resource "aws_route_table" "rt_b" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat_gw_b.id}"
  }

  tags {
    Name        = "${local.domain}-route_table_subnet_b"
    environment = "global"
  }
}

resource "aws_route_table" "rt_c" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat_gw_c.id}"
  }

  tags {
    Name        = "${local.domain}-route_table_subnet_c"
    environment = "global"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.config["subnet.subnet_b.cidr_block"]}"
  availability_zone = "${local.region}b"

  tags {
    Name        = "${local.domain}-subnet_b"
    Access      = "private"
    environment = "global"
  }
}

resource "aws_subnet" "subnet_c" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.config["subnet.subnet_c.cidr_block"]}"
  availability_zone = "${local.region}c"

  tags {
    Name        = "${local.domain}-subnet_c"
    Access      = "private"
    environment = "global"
  }
}

resource "aws_route_table_association" "rt_assc_b" {
  subnet_id      = "${aws_subnet.subnet_b.id}"
  route_table_id = "${aws_route_table.rt_b.id}"
}

resource "aws_route_table_association" "rt_assc_c" {
  subnet_id      = "${aws_subnet.subnet_c.id}"
  route_table_id = "${aws_route_table.rt_c.id}"
}

##############################################################################
# VPC Security Group
##############################################################################

resource "aws_security_group" "sg" {
  name   = "${local.domain}-sg"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    self      = "true"
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${local.domain}-sg"
    environment = "global"
  }
}

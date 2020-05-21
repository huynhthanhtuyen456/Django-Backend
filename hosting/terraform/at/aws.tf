variable "config" {
  type = "map"
}

# check for presence of all config variables
locals {
  region   = "${var.config["region"]}"
  profile = "${var.config["aws_profile"]}"
  account_id   = "${var.config["account_id"]}"
  ubuntu_ami   = "${var.config["ubuntu_ami"]}"
}

provider "aws" {
  region = "${local.region}"
  profile = "${var.config["profile"]}"
}

data "aws_vpc" "vpc" {
  tags = {
    Name                                  = "${var.config["domain"]}"
  }
}

data "aws_subnet" "vpc_subnet_public" {
  cidr_block        = "10.0.64.0/20"
  availability_zone = "${local.region}b"

  tags {
    Name = "vpc_subnet_public_b"
  }
}

data "aws_security_group" "vpc_web_access" {
  name = "web_access"
}
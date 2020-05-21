variable "config" {
  type = "map"
}

locals {
  region = "${var.config["region"]}"
  account_id = "${var.config["account_id"]}"
  ssh_key_name = "${var.config["ssh_key_name"]}"
  env = "${var.config["env"]}"
  domain = "${local.env}-${var.config["domain"]}"
  ubuntu_ami   = "${var.config["ubuntu_ami"]}"
}

provider "aws" {
  region = "${local.region}"
  profile = "${var.config["profile"]}"
}

data "aws_vpc" "vpc" {
  tags = {
    Name                                  = "${local.domain}"
  }
}

data "aws_security_group" "sg" {
  name = "${local.domain}-sg"
}

data "aws_subnet" "subnet_public" {
  tags {
    Name = "${local.domain}-subnet_public_b"
  }
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags {
    Name = "${local.domain}-subnet_public_*"
  }
}

resource "aws_security_group" "web_access" {
  name        = "${local.domain}-web_access"
  description = "web access for machine"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${local.domain}-web_access"
  }
}

resource "aws_security_group" "ssh" {
  name        = "${local.domain}-ssh"
  description = "ssh access for machine"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${local.domain}-ssh"
  }
}

resource "aws_security_group" "sg_elb_production" {
  name        = "${local.domain}-elb_production"
  description = "web access for machine"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "${local.domain}-elb_production"
  }
}

resource "aws_instance" "aws_instance_api_production" {
  ami                         = "${local.ubuntu_ami}"
  instance_type               = "t2.medium"
  key_name                    = "${local.ssh_key_name}"
  subnet_id                   = "${data.aws_subnet.subnet_public.id}"
  disable_api_termination     = "true"
  monitoring                  = "true"
  associate_public_ip_address = "true"

  root_block_device = {
    volume_size = "100"
  }

  vpc_security_group_ids = ["${aws_security_group.web_access.id}", "${data.aws_security_group.sg.id}", "${aws_security_group.ssh.id}"]

  tags {
    Name        = "${local.domain}-api"
    environment = "global"
  }
}

resource "aws_eip" "master_instance_eip" {
  instance   = "${aws_instance.aws_instance_api_production.id}"
  depends_on = ["aws_instance.aws_instance_api_production"]
}

resource "aws_elb" "elb_production" {
  name               = "${local.env}-elb"
  subnets            = ["${data.aws_subnet_ids.subnet_ids.ids}"]
  security_groups    = ["${aws_security_group.sg_elb_production.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

/*
  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    // ssl_certificate_id = ""
  }
*/

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP/elb-status/"
    interval            = 30
  }

  instances                   = ["${aws_instance.aws_instance_api_production.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${local.domain}-elb-production"
  }
}

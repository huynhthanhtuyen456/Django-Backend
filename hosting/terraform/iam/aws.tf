variable "config" {
  type = "map"
}

provider "aws" {
  region = "${var.config["region"]}"
  profile = "${var.config["profile"]}"
}

locals {
  region = "${var.config["region"]}"
  account_id = "${var.config["account_id"]}"
  env = "${var.config["env"]}"
  domain = "${local.env}-${var.config["domain"]}"
}

data "aws_vpc" "vpc" {
  tags = {
    Name                                  = "${local.domain}"
  }
}

data "aws_security_group" "sg" {
  name = "${local.domain}-sg"
}

resource "aws_kms_key" "vpc_variables" {
  description             = "${local.env} VPC Variables"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "vpc_variables" {
  name          = "alias/${local.env}-vpc-variables"
  target_key_id = "${aws_kms_key.vpc_variables.key_id}"
}

resource "aws_iam_role" "lambda" {
    name = "lambda"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

variable "iam_policy_arn" {
  type = "list"
  default = [
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonSESFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  ]
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = "${aws_iam_role.lambda.name}"
  count      = "${length(var.iam_policy_arn)}"
  policy_arn = "${var.iam_policy_arn[count.index]}"
}


resource "aws_security_group" "public_access" {
  name        = "${local.domain}-public_db_access"
  description = "${local.domain} publicly accessible"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${data.aws_security_group.sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "public_db_access"
  }
}
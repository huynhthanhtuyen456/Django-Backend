variable "config" {
  type = "map"
}

provider "aws" {
  region = "${var.config["region"]}"
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

resource "aws_sns_topic" "topic_name" {
  name = "${local.env}-sms-notifications"
}
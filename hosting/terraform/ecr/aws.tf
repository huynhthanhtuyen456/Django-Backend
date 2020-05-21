variable "config" {
  type = "map"
}

provider "aws" {
  region = "${var.config["region"]}"
  profile = "${var.config["profile"]}"
}

data "aws_vpc" "vpc" {
  tags = {
    Name                                  = "${var.config["domain"]}"
  }
}

resource "aws_ecr_repository" "ecr_repo" {
  name = "ECR Repo"
}
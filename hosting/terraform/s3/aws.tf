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

resource "aws_s3_bucket" "mobile_video_s3_upload" {
  bucket = "${var.config["account_id"]}-${var.config["region"]}-mobile-upload"
  acl    = "public-read"
  force_destroy = true
  versioning {
    enabled = true
  }
}


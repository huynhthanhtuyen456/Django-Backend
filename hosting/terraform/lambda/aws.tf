variable "config" {
  type = "map"
}
variable "arns" {
  type = "list"
}
locals {
  sns_mobile_video_upload_lambda_artifact = "../../../lambda/dist/sns-s3-mobile-upload.zip" // must be a zip file
}

provider "aws" {
  region = "${var.config["region"]}"
}

data "aws_iam_role" "lambda" {
    name = "lambda"
}

data "aws_sns_topic" "upload" {
  name = "s3-mobile-upload-event-notification"
}

resource "aws_lambda_function" "upload" {
  function_name = "s3-sns-mobile-upload"
  filename = "${local.sns_mobile_video_upload_lambda_artifact}"
  source_code_hash = "${base64sha256(file(local.sns_mobile_video_upload_lambda_artifact))}"
  handler = "lambda.handler"
  runtime = "python3.6"
  role = "${data.aws_iam_role.lambda.arn}"
  memory_size = 1024
  timeout = 5
}

resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.upload.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn = "${data.aws_sns_topic.upload.arn}"
}
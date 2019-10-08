resource "aws_s3_bucket" "this" {
  bucket = "example"
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "../lambda-functions/loadbalancer-to-es"
  output_path = "../lambda-functions/loadbalancer-to-es.zip"
}

# upload zip to s3 and then update lamda function from s3
resource "aws_s3_bucket_object" "file_upload" {
  bucket = "${aws_s3_bucket.this.id}"
  key    = "lambda-functions/loadbalancer-to-es.zip"
  source = "${data.archive_file.source.output_path}" # its mean it depended on zip
}

resource "aws_lambda_function" "this" {
  function_name    = "${var.lambda_function_name}"
  role             = "${aws_iam_role.this.arn}"                                                //to be check
  handler          = "${var.lambda_handler}"
  s3_bucket        = "${var.s3_bucket}"
  s3_key           = "${var.s3_key}"
  runtime          = "${var.lambda_runtime}"
  timeout          = 60
  description      = "Create Lambda"

  environment {
    variables {
      VAR1 = "${var.demo}"
    }
  }
}

resource “aws_s3_bucket_object” “file_upload” {
 bucket = “${var.s3_bucket}”
 key = “${var.s3-crawler-deploy-key}”
 source = “${data.archive_file.zipit.output_path}”
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/this.zip"
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
  source_arn    = "${var.aws_kibana_sns_topic}"
  function_name = "${aws_lambda_function.this.arn}"
}

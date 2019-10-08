provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "this" {
  bucket = "terraformcreatedbucket"
  region = "us-east-1"
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-function"
  output_path = "${path.module}/lambda-function.zip"
}

# upload zip to s3 and then update lamda function from s3
resource "aws_s3_bucket_object" "file_upload" {
  bucket = "${aws_s3_bucket.this.id}"
  key    = "${path.module}/lambda-function.zip"
  source = "${data.archive_file.source.output_path}" # its mean it depended on zip
}

resource "aws_lambda_function" "this" {
  function_name = "${var.lambda_function_name}"
  role          = "${aws_iam_role.iam_for_lambda_tf.arn}"   //to be check
  handler       = "${var.lambda_handler}"
  s3_bucket     = "${aws_s3_bucket.this.id}"
  s3_key        = "${aws_s3_bucket_object.file_upload.key}"
  runtime       = "python2.7"
  timeout       = 60
  description   = "Create Lambda"

  environment {
    variables {
      VAR1 = "${var.demo}"
    }
  }
}

resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "This is my API for demonstration purposes"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.this.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.MyDemoAPI.execution_arn}/*/*/*"
}

# Necessary permissions to create/run the function 
resource "aws_iam_role" "iam_for_lambda_tf" {
  name = "iam_for_lambda_tf"

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

provider "aws" {
    alias = "acm"
    region = "us-east-1"
}

resource "aws_iam_role" "_" {
  name = "${var.name}_lambda_exec"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "_" {
    source_json = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
    override_json = var.extra_policy_statements
}

resource "aws_iam_policy" "_" {
  name = "${var.name}_lambda_exec"
  path = "/"
  description = "IAM policy for a lambda ${var.name}"
  policy = data.aws_iam_policy_document._.json
}

resource "aws_iam_role_policy_attachment" "_" {
  role = aws_iam_role._.name
  policy_arn = aws_iam_policy._.arn
}

resource "aws_lambda_function" "_" {
  provider = aws.acm  # for cloudfront
  publish  = true     # for cloudfront

  function_name    = var.name
  filename         = var.function_filename
  source_code_hash = filebase64sha256(var.function_filename)
  role             = aws_iam_role._.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"
}


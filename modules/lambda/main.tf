resource "aws_iam_role" "this" {
  name = "${var.name}_lambda_exec"

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

data "aws_iam_policy_document" "this" {
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
    },
    {
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "${aws_lambda_function.this.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
    override_json = var.extra_policy_statements
}

resource "aws_iam_policy" "this" {
  name = "${var.name}_lambda_exec"
  path = "/"
  description = "IAM policy for a lambda ${var.name}"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_lambda_function" "this" {
  filename      = var.function_filename
  source_code_hash = filebase64sha256(var.function_filename)
  timeout       = var.timeout
  function_name = var.name
  role          = aws_iam_role.this.arn
  handler       = "index.handler"
  runtime       = "nodejs10.x"
  environment {
    variables = var.environment_variables
  }
}


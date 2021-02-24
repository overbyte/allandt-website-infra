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

  function_name = var.name
  role          = aws_iam_role.this.arn
  handler       = "index.handler"
  runtime       = "nodejs10.x"
  environment {
    variables = var.environment_variables
  }

  # XPKIT jobs polling is slow and spikey - lets be safe.
  timeout = var.timeout
}

resource "aws_apigatewayv2_route" "this" {
  count = var.skip_authorizer ? 0 : 1

  route_key             = var.route_key
  api_id                = var.api_id
  authorization_scopes  = var.authorization_scopes
  authorization_type    = "JWT"
  authorizer_id         = var.authorizer_id

  # https://github.com/terraform-providers/terraform-provider-aws/issues/12972
  # The integration must be specified here otherwise the link will not be made -
  # outside of 'quick create' this option is mandatory - contra to the docs
  # recommendation
  target = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_route" "unauth" {
  count = var.skip_authorizer ? 1 : 0

  route_key             = var.route_key
  api_id                = var.api_id

  # https://github.com/terraform-providers/terraform-provider-aws/issues/12972
  # The integration must be specified here otherwise the link will not be made -
  # outside of 'quick create' this option is mandatory - contra to the docs
  # recommendation
  target = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_integration" "this" {
  api_id           = var.api_id
  integration_type = "AWS_PROXY"

  description               = "${var.name} for ${var.route_key}"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.this.invoke_arn
  payload_format_version    = "2.0"
  # set this default otherwise it will always trigger an update for some reason
  passthrough_behavior   = "WHEN_NO_MATCH"
}

resource "aws_lambda_permission" "this" {
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.this.function_name
    principal     = "apigateway.amazonaws.com"

    source_arn = "${var.api_execution_arn}/*/*"
}

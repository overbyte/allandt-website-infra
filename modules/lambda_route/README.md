# Lambda Routes for API Gateway V2

This is a crude module to DRY out creating lambdas - its here more as a working
example rather than a piece of production configuration.

## TODO

* output variables
* move lambda out? 

## Example

```
module "api_gateway_lambda_route" {
    source                  = "./modules/lambda_route"
    name                    = "test_function"
    api_id                  = aws_apigatewayv2_api.api.id
    api_execution_arn       = aws_apigatewayv2_api.api.execution_arn
    authorizer_id           = aws_apigatewayv2_authorizer.authorizer.id
    function_filename       = "test.zip"
    route_key               = "GET /token"
    authorization_scopes    = ["read:some-thing"]
}

resource "aws_apigatewayv2_api" "api" {
    name          = "${local.project}_api"
    protocol_type = "HTTP"
    cors_configuration {
        allow_headers = ["*"]
        allow_methods = ["*"]
        allow_origins = ["*"]
    }
}

resource "aws_apigatewayv2_authorizer" "authorizer" {
  api_id           = aws_apigatewayv2_api.api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "auth0-authorizer"

  jwt_configuration {
    audience = ["apig-testing-id"]
    issuer   = "https://ford-horizon.eu.auth0.com/"
  }
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.api.id
  name   = "default"
}

resource "aws_apigatewayv2_deployment" "deployment" {
    depends_on = [
        module.api_gateway_lambda_route
    ]
    api_id      = aws_apigatewayv2_api.api.id
    description = "deployment"

    lifecycle {
        create_before_destroy = true
    }
}
```

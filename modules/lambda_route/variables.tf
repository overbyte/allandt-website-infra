variable "name" {
  description = "The name of the lambda function and this module instance"
  type        = string
  default     = ""
}
variable "api_id" {
  description = "The id of the aws_apigatewayv2_api"
  type        = string
  default     = ""
}
variable "api_execution_arn" {
  description = "The execution arn of the aws_apigatewayv2_api"
  type        = string
  default     = ""
}
variable "authorizer_id" {
  description = "The id of the aws_apigatewayv2_authorizer"
  type        = string
  default     = ""
}
variable "function_filename" {
  description = "The local path to the lambda function .zip file"
  type        = string
  default     = ""
}
variable "route_key" {
  description = "The http verb and path separated by a space"
  type        = string
  default     = ""
}
variable "authorization_scopes" {
  description = "A list of scopes to apss the the authorizer"
  type        = list(string)
  default     = []
}
variable "environment_variables" {
  description = "A map of environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}
variable "extra_policy_statements" {
  description = "Extra rules to appended to the policy statement"
  type        = string
  default     = ""
}
variable "skip_authorizer" {
  description = "make this route open to the web"
  type        = bool
  default     = false
}
variable "timeout" {
  description = "The time the lamba is allowed to run for"
  type        = number
  default     = 15
}

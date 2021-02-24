variable "name" {
  description = "The name of the lambda function and this module instance"
  type        = string
  default     = ""
}
variable "function_filename" {
  description = "The local path to the lambda function .zip file"
  type        = string
  default     = ""
}
variable "environment_variables" {
  description = "A map of environment variables for the Lambda Function."
  type        = map(string)
  default     = { DUMMY="DUMMY" }
}
variable "extra_policy_statements" {
  description = "Extra rules to appended to the policy statement"
  type        = string
  default     = ""
}
variable "timeout" {
  description = "The time the lamba is allowed to run for"
  type        = number
  default     = 3
}

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
variable "extra_policy_statements" {
  description = "Extra rules to appended to the policy statement"
  type        = string
  default     = ""
}

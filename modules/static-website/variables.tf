variable "name" {
  description = "the name for the resources this module creates"
}
variable "tags" {
  description = "resource tags"
  type        = map(string)
}
variable "fqdn" {
  description = "fully qualified domain name (dev.example.com)"
}
variable "disable_ttl" {
  description = "disable the ttl on the default cache for testing environments"
  default = false
}

variable "lambdas" {
  description = "a list of edge lambdas and their config"
  type = list(object({
    event_type   = string
    include_body = bool
    lambda_arn   = string
  }))
}

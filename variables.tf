variable "workspace" {
  description = "the workspace name from terraform.io"
}
variable "branch_name" {
  description = "the branch that codepiplines pull source from for this workspace"
}
variable "basic_auth_entries" {
  description = "a CSV of colon separated usernames and passwords (user1:pass1,user2:pass2)"
  sensitive = true
}
variable "zone_id" {
  description = "The Domain Name for the website"
}
variable "qualified_domain_name" {
    description = "The fully qualified domain name"
}

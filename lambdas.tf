#===============================================================================
# this provides simple basic auth functionality. The template file is used so we
# can add valid basic auth usernames and passwords to the lambda. These are
# calculated before they are injected into the function.

data "template_file" "edge_basic_auth" {
  template = file("./lambdas/edge_basic_auth/index.tpl")
  vars = {
    BASIC_AUTH_ENTRIES = var.basic_auth_entries
  }
}

data "archive_file" "edge_basic_auth" {
  type = "zip"
  source {
    content  = data.template_file.edge_basic_auth.rendered
    filename = "index.js"
  }
  output_path = "lambdas/edge_basic_auth.zip"
}


module "edge_basic_auth" {
  source                  = "./modules/lambda-edge"
  name                    = "${local.namespace}_edge_basic_auth"
  function_filename       = "./lambdas/edge_basic_auth.zip"
}


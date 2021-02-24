#===============================================================================
# This file contains the modules that make up the static websites

module "website" {
  source = "./modules/static-website"

  name = "${local.namespace_dash}-website"
  fqdn = "${var.workspace}.wearebulletproof.com"
  disable_ttl = var.workspace == "production" ? false : true

  lambdas = [
    {
      event_type   = "viewer-request"
      lambda_arn   = module.edge_basic_auth.function_qualified_arn
      include_body = false
    }
]

  tags = local.tags
}


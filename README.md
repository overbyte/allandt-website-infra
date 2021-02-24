# Terraform Website Infrastructure

This creates the following AWS infrastructure to enable a website deployment
from app.terraform.io:

* IAM policy to enable viewer and private access
* ACM Certificate for TLS
* S3 for file storage
* Cloudfront for CDN distribution (with history mode for SPAs)


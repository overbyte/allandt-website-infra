provider "aws" {                                                                      
    alias = "us_east_1"                                                                
    region = "us-east-1"                                                              
}                                                                                      

data "aws_route53_zone" "lookup" {
  name = "allandt.com."
}

resource "aws_acm_certificate" "_" {                                                  
  domain_name       = var.qualified_domain_name                                        
  validation_method = "DNS"                                                            
  provider          = aws.us_east_1                                                    
}                                                                                      
                                                                                       
resource "aws_route53_record" "validation" {                                          
  for_each = {                                                                        
    for dvo in aws_acm_certificate._.domain_validation_options : dvo.domain_name
=> {  
      name   = dvo.resource_record_name                                                
      record = dvo.resource_record_value                                              
      type   = dvo.resource_record_type                                                
    }                                                                                  
  }                                                                                    
                                                                                       
  # https://github.com/terraform-providers/terraform-provider-aws/issues/7918          
  allow_overwrite = true                                                              
  name    = each.value.name                                                            
  records = [each.value.record]                                                        
  ttl     = 60                                                                        
  type    = each.value.type                                                            
  zone_id = data.aws_route53_zone.lookup.zone_id
}                                                                                      
                                                                                       
resource "aws_acm_certificate_validation" "_" {                                        
  certificate_arn         = aws_acm_certificate._.arn                                  
  validation_record_fqdns = [for record in aws_route53_record.validation :
record.fqdn]
  provider                = aws.us_east_1                                              
}                                                                                      
                                                                                       
resource "aws_route53_record" "beanstalk" {                                            
  depends_on = [                                                                      
    aws_cloudfront_distribution.website                                                
  ]                                                                                    
  zone_id       = data.aws_route53_zone.lookup.zone_id
  name          = var.qualified_domain_name                                            
  type          = "A"                                                                  
  alias {                                                                              
    name        = aws_cloudfront_distribution.website.domain_name                      
    zone_id     = aws_cloudfront_distribution.website.hosted_zone_id                  
    evaluate_target_health  = true                                                    
  }                                                                                    
}              

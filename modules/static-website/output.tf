output "bucket_name" {
  value = aws_s3_bucket._.id
}
output "bucket_arn" {
  value = aws_s3_bucket._.arn
}
output "distribution_id" {
  value = aws_cloudfront_distribution._.id
}
output "distribution_arn" {
  value = aws_cloudfront_distribution._.arn
}
output "distribution_domain_name" {                  
  value = aws_cloudfront_distribution._.domain_name  
}                                                    

output "distribution_hosted_zone_id" {                
  value = aws_cloudfront_distribution._.hosted_zone_id
}         

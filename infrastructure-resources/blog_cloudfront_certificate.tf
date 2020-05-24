resource "aws_acm_certificate" "blog_cloudfront" {
  provider    = aws.aws_us
  domain_name = "volatilethunk.com"
}


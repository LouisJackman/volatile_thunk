resource "aws_s3_bucket_policy" "blog_bucket" {
  bucket = "volatilethunk.com"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = "s3:GetObject",
          Condition = {
            StringLike = {
              "aws:Referer" = var.s3_referrer_token
            }
          },
          Effect    = "Allow",
          Principal = "*",
          Resource  = "arn:aws:s3:::volatilethunk.com/*",
          Sid       = "PublicReadGetObject",
        },
      ]
      Version : "2012-10-17"
    }
  )
}


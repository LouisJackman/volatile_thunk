resource "aws_s3_bucket" "blog_bucket" {
  bucket = "volatilethunk.com"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}


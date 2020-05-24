resource "aws_s3_bucket" "blog_bucket" {
  bucket = "volatilethunk.com"

  website {
    index_document = "index.html"
  }
}


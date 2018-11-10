terraform {
  version = "0.11"

  backend "s3" {
    bucket = "volatilethunk.com-terraform-state"
    key    = "tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  version = "1.39"
  region  = "eu-west-2"
}

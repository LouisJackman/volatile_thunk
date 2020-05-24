terraform {
  backend "s3" {
    bucket = "volatilethunk.com-terraform-state"
    key    = "tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  version = "2.63"
  region  = "eu-west-2"
}


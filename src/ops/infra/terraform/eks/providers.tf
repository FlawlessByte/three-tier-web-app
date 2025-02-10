# Configure the AWS provider
provider "aws" {
  region = var.region
  default_tags {
    tags = var.tags
  }
}
# Configure the AWS provider
provider "aws" {
  region = var.region
  default_tags {
    tags = local.all_tags
  }
}
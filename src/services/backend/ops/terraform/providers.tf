# Configure the AWS provider
provider "aws" {
  region = var.region
  default_tags {
    tags = merge(
      var.default_tags,
      var.additional_tags
    )
  }
}
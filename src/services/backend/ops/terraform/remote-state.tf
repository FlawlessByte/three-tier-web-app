terraform {
  backend "s3" {
    bucket               = "toptal-terraform-tfstate"
    workspace_key_prefix = "src/services/node-api"
    region               = "eu-west-2"
    key                  = "terraform.tfstate"
    # TODO: Uncomment the following line to enable locking
    # dynamodb_table       = "terraform_locks"
  }
}
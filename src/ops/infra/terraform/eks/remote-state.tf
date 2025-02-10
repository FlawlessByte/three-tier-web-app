terraform {
  backend "s3" {
    bucket               = "toptal-terraform-tfstate"
    workspace_key_prefix = "terraform/eks"
    region               = "eu-west-2"
    key                  = "terraform.tfstate"
    # dynamodb_table       = "terraform_locks"
  }
}
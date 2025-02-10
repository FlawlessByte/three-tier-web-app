name   = "webapp"
region = "eu-west-2"

ecr_create = true

# additional tags
additional_tags = {
  "Environment"       = "production"
  "ResourceCreatedBy" = "terraform"
}
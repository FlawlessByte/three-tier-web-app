name   = "backend"
region = "eu-west-2"

# Not used
vpc_id = "vpc-0deff1a14f364d779"

ecr_create = true

# additional tags
additional_tags = {
  "Environment"       = "production"
  "ResourceCreatedBy" = "terraform"
}
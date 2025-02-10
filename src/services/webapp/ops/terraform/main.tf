locals {
  all_tags = merge(var.default_tags, var.additional_tags)
}

################################################################################
# The CloudFront Distribution
################################################################################
locals {
  cloudfront_comment                       = coalesce(var.cloudfront_comment, "UI for ${var.name}")
  cloudfront_aliases                       = var.cloudfront_aliases
  cloudfront_create_origin_access_identity = var.cloudfront_create_origin_access_identity && var.cloudfront_distribution_create
  # cloudfront_origin_access_identities = {
  #   s3 = "${var.name}"
  # }
  cloudfront_origin_name            = coalesce(var.cloudfront_origin_name, var.name)
  cloudfront_default_cache_behavior = merge({ target_origin_id = var.cloudfront_cached_domain_name }, var.cloudfront_default_cache_behavior)

  cloudfront_origin = {
    "${var.cloudfront_cached_domain_name}" = {
      domain_name = var.cloudfront_cached_domain_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }
}

module "cloudfront_distribution" {
  create_distribution = var.cloudfront_distribution_create
  source              = "terraform-aws-modules/cloudfront/aws"
  version             = "4.1.0"

  aliases                       = local.cloudfront_aliases
  comment                       = local.cloudfront_comment
  is_ipv6_enabled               = var.cloudfront_is_ipv6_enabled
  price_class                   = var.cloudfront_price_class
  create_origin_access_identity = local.cloudfront_create_origin_access_identity
  origin_access_identities      = var.cloudfront_origin_access_identities
  origin                        = local.cloudfront_origin
  default_cache_behavior        = local.cloudfront_default_cache_behavior
  viewer_certificate            = var.cloudfront_viewer_certificate
  custom_error_response         = var.cloudfront_custom_error_response
  tags = local.all_tags
}

locals {
  ecr_name = coalesce(var.ecr_name, var.name)
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.3.0"

  create                          = var.ecr_create
  repository_name                 = local.ecr_name
  repository_image_tag_mutability = var.ecr_image_tag_mutability
  repository_image_scan_on_push   = var.ecr_repository_image_scan_on_push
  repository_encryption_type      = var.ecr_encryption_type
  create_lifecycle_policy         = false
  create_repository_policy        = false
  attach_repository_policy        = false
}

module "secrets_manager" {
  source                  = "terraform-aws-modules/secrets-manager/aws"
  version                 = "1.1.2"
  create                  = var.secrets_manager_create
  name                    = var.name
  description             = "This is a key/value secret for ${var.name}"
  recovery_window_in_days = 7
  # TODO: Update the AWS_SECRETS automatically
  secret_string = jsonencode({
    AWS_REGION = "${var.region}"
    }
  )
  ignore_secret_changes = true
}
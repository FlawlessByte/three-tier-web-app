variable "name" {
  description = "A prefix used for naming resources."
  type        = string
  default     = ""
}
variable "region" {
  type    = string
  default = "eu-west-2"
}
variable "default_tags" {
  default = {
    "CreatedUsing"   = "Terraform"
  }
  description = "Additional resource tags"
  type        = map(string)
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

# s3
variable "cloudfront_s3_create" {
  description = "Create the S3 resoure?"
  type        = bool
  default     = true
}
variable "cloudfront_s3_bucket_name" {
  description = "The name of the S3 bucket for storing the webapp static contents"
  type        = string
  default     = ""
}

# CloudFront
variable "cloudfront_distribution_create" {
  description = "Controls if CloudFront distribution should be created"
  type        = bool
  default     = false
}
variable "cloudfront_create_origin_access_identity" {
  description = "Controls if CloudFront origin access identity should be created"
  type        = bool
  default     = true
}
variable "cloudfront_origin_access_identities" {
  description = "Map of CloudFront origin access identities (value as a comment)"
  type        = map(string)
  default     = {}
}
variable "cloudfront_aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
  default     = []
}
variable "cloudfront_comment" {
  description = "Any comments you want to include about the distribution."
  type        = string
  default     = null
}
variable "cloudfront_is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution."
  type        = bool
  default     = true
}
variable "cloudfront_price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_All"
}
variable "cloudfront_origin" {
  description = "One or more origins for this distribution (multiples allowed)."
  type        = any
  default     = {}
}
variable "cloudfront_viewer_certificate" {
  description = "The SSL configuration for this distribution"
  type        = any
  default = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:392347600144:certificate/b883070f-53a9-4775-ad6d-aaaeda9f8602"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}
variable "cloudfront_custom_error_response" {
  description = "One or more custom error response elements"
  type        = any
  default = [{
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }]
}
variable "cloudfront_default_cache_behavior" {
  description = "The default cache behavior for this distribution"
  type        = any
  default = {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true
    use_forwarded_values   = false
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }
}

variable "cloudfront_origin_name" {
  description = "The origin name for Cloudfront"
  type        = string
  default     = ""
}

# ecr
variable "ecr_name" {
  default     = ""
  type        = string
  description = "Name of the ECR repository"
}
variable "ecr_create" {
  default     = false
  type        = bool
  description = "Create ECR repository"
}
variable "ecr_image_tag_mutability" {
  default     = "IMMUTABLE"
  type        = string
  description = "The tag mutability setting for the repository"
}
variable "ecr_encryption_type" {
  default     = "AES256"
  type        = string
  description = "The encryption type for the repository"
}
variable "ecr_repository_image_scan_on_push" {
  default     = false
  type        = bool
  description = "Whether images are scanned for vulnerabilities"
}

# secrets manager
variable "secrets_manager_create" {
  description = "Create the Secrets Manager resoure?"
  type        = bool
  default     = false
}

variable "cloudfront_cached_domain_name" {
  description = "The domain name for caching"
  type        = string
  default     = ""
}
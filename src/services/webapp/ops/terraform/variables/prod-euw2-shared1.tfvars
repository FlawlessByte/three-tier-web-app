name = "webapp-prod-euw2-shared1"
region = "eu-west-2"

cloudfront_aliases = [
  "webapp-prod-euw2-shared1.flawlessbyte.dev"
]
cloudfront_cached_domain_name = "webapp-prod-euw2-shared1.flawlessbyte.dev"
cloudfront_distribution_create = true

secrets_manager_create = true
name   = "backend-prod-euw2-shared1"
region = "eu-west-2"

vpc_id = "vpc-0deff1a14f364d779"

rds_create            = true
rds_instance_class    = "db.t4g.micro"
rds_engine_version    = "15.10"
rds_allocated_storage = "5"
rds_storage_type      = "gp2"
rds_iops              = 0
rds_db_name           = "backend"
rds_username          = "postgres"

# Toggle the following values in production
rds_multi_az            = false
rds_deletion_protection = false
rds_parameters = [
  {
    name  = "rds.force_ssl"
    value = "0"
  }
]

secrets_manager_create = true
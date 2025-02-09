locals {
  rds_identifier                = coalesce(var.rds_identifier, var.name)
  rds_subnet_ids                = length(var.vpc_private_subnet_ids) > 0 ? var.vpc_private_subnet_ids : data.aws_subnets.private.ids
  rds_create_db_subnet_group    = var.rds_create && var.rds_create_db_subnet_group
  rds_subnet_group_name         = coalesce(var.rds_subnet_group_name, var.name)
  rds_create_db_parameter_group = var.rds_create && var.rds_create_db_parameter_group
  rds_derived_sg_protocols = var.rds_create ? [
    {
      description = "Ingress from ${var.vpc_id} (managed by Terraform)"
      from_port   = "5432"
      to_port     = "5432"
      protocol    = "tcp"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
    }
  ] : []
  rds_sg_protocols = length(var.rds_sg_protocols) > 0 ? var.rds_sg_protocols : local.rds_derived_sg_protocols
}

module "rds_security_group" {
  create  = var.rds_create
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  use_name_prefix          = var.rds_sg_use_name_prefix
  name                     = "rds-${var.name}"
  description              = "RDS Security group for ${var.name}"
  vpc_id                   = var.vpc_id
  ingress_with_cidr_blocks = local.rds_sg_protocols
  egress_rules             = ["all-all"]
}

module "rds" {
  create_db_instance = var.rds_create
  source             = "terraform-aws-modules/rds/aws"
  version            = "6.5.4"

  parameter_group_use_name_prefix                        = var.rds_parameter_group_use_name_prefix
  create_db_parameter_group                              = local.rds_create_db_parameter_group
  parameters                                             = var.rds_parameters
  family                                                 = var.rds_parameter_group_family
  instance_class                                         = var.rds_instance_class
  create_db_subnet_group                                 = local.rds_create_db_subnet_group
  db_subnet_group_name                                   = local.rds_subnet_group_name
  db_subnet_group_use_name_prefix                        = var.rds_subnet_group_use_name_prefix
  subnet_ids                                             = local.rds_subnet_ids
  identifier                                             = local.rds_identifier
  db_name                                                = var.rds_db_name
  username                                               = var.rds_username
  port                                                   = var.rds_port
  copy_tags_to_snapshot                                  = var.rds_copy_tags_to_snapshot
  apply_immediately                                      = var.rds_apply_immediately
  deletion_protection                                    = var.rds_deletion_protection
  multi_az                                               = var.rds_multi_az
  allocated_storage                                      = var.rds_allocated_storage
  max_allocated_storage                                  = var.rds_max_allocated_storage
  storage_type                                           = var.rds_storage_type
  engine                                                 = var.rds_engine
  engine_version                                         = var.rds_engine_version
  vpc_security_group_ids                                 = [module.rds_security_group.security_group_id]
  manage_master_user_password                            = var.rds_manage_master_user_password
  manage_master_user_password_rotation                   = var.rds_manage_master_user_password_rotation
  master_user_password_rotation_automatically_after_days = var.rds_master_user_password_rotation_automatically_after_days
  performance_insights_enabled                           = var.rds_performance_insights_enabled
  backup_window           = "03:00-06:00"
  # TODO: update the retention period for prod 
  backup_retention_period = 1
}


# Gather VPC details from the VPC id
data "aws_vpc" "vpc" {
  id       = var.vpc_id
}

# Get the private subnets only
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["private*"]
  }
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
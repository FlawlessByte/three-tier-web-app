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

# VPC
variable "vpc_id" {
  default     = ""
  description = "Identifier of the VPC where the resources are to be created"
  type        = string
}

# RDS
variable "rds_create" {
  description = "Create the RDS resoure?"
  type        = bool
  default     = false
}
variable "rds_sg_protocols" {
  description = "A map of security group ingress rules for RDS"
  type        = list(map(string))
  default     = []
}
variable "rds_sg_use_name_prefix" {
  description = "Use a prefix for the RDS SG name"
  type        = bool
  default     = false
}
variable "rds_parameter_group_use_name_prefix" {
  description = "Use a prefix for the parameter group name"
  type        = bool
  default     = false
}
variable "rds_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.m6g.large"
}
variable "rds_identifier" {
  description = "The name of the RDS instance"
  type        = string
  default     = null
}
variable "rds_storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'standard' if not. Note that this behaviour is different from the AWS web console, where the default is 'gp2'."
  type        = string
  default     = "gp3"
}
variable "rds_engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}
variable "rds_engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "13.15"
}
variable "rds_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = string
  default     = "20"
}
variable "rds_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "postgres"
}
variable "rds_port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = "5432"
}
variable "rds_copy_tags_to_snapshot" {
  description = "On delete, copy all Instance tags to the final snapshot"
  type        = bool
  default     = "true"
}
variable "rds_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = true
}
variable "rds_apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = true
}
variable "rds_deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
  # TODO: Change to true after tests
  default     = true
}
variable "rds_max_allocated_storage" {
  description = "Specifies the value for Storage Autoscaling"
  type        = number
  default     = 30
}
variable "rds_iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'"
  type        = number
  default     = 3000
}
variable "rds_create_db_subnet_group" {
  description = "Whether to create a database subnet group"
  type        = bool
  default     = true
}
variable "rds_create_db_parameter_group" {
  description = "Whether to create a database parameter group"
  type        = bool
  default     = true
}
variable "rds_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC"
  type        = string
  default     = null
}
variable "rds_subnet_group_use_name_prefix" {
  description = "Determines whether to use `subnet_group_name` as is or create a unique name beginning with the `subnet_group_name` as the prefix"
  type        = bool
  default     = false
}
variable "rds_manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type        = bool
  default     = true
}
variable "rds_manage_master_user_password_rotation" {
  description = "Whether to manage the master user password rotation. By default, false on creation, rotation is managed by RDS. Setting this value to false after previously having been set to true will disable automatic rotation."
  type        = bool
  default     = false
}
variable "rds_master_user_password_rotation_automatically_after_days" {
  description = "Specifies the number of days between automatic scheduled rotations of the secret. Either automatically_after_days or schedule_expression must be specified."
  type        = number
  default     = 7
}
variable "rds_parameters" {
  description = "A list of DB parameters (map) to apply"
  type        = list(map(string))
  default     = []
}
variable "rds_parameter_group_family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = "postgres15"
}
variable "rds_db_name" {
  description = "The DB name to create. If omitted, no database is created initially"
  type        = string
  default     = "api"
}
variable "rds_performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = false
}
variable "vpc_private_subnet_ids" {
  description = "The private subnet IDs"
  type        = list(string)
  default     = []
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
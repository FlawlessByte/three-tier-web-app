variable "region" {
  default = "eu-west-2"
}

variable "tags" {
  default = {}
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block"
  type        = string
  default     = null
}

variable "az_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}

variable "public_subnet_names" {
  description = "List of public subnet names"
  type        = list(string)
  default     = []
}
variable "private_subnet_names" {
  description = "List of private subnet names"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = []
}
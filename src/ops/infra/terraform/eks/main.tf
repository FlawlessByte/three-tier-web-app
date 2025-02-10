data "aws_availability_zones" "available" {
  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name   = var.name
  region = var.region

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  tags = var.tags
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = coalesce(var.private_subnets, [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)])
  public_subnets  = coalesce(var.public_subnets, [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)])

  private_subnet_names = var.private_subnet_names
    public_subnet_names  = var.public_subnet_names

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.31"

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-ebs-csi-driver = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["m6a.large", "m5a.large", "c5a.large", "c6a.large"]
      capacity_type  = "SPOT"

      min_size = 1
      max_size = 3

      desired_size = 1
    }
  }

  iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      # TODO: Not safe, but for testing purposes. Need to be more specific.
      AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
    #   SecretsManagerReadWrite = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
    #   AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  }

  tags = local.tags
}

module "load_balancer_controller_irsa" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "load-balancer-controller-${local.name}"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["ext-alb-controller:aws-load-balancer-controller"]
    }
  }
  tags = local.tags
}

output "load_balancer_controller_irsa_role_arn" {
  value = module.load_balancer_controller_irsa.iam_role_arn
}

module "external_secrets_irsa_role" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                                          = "external-secrets-${local.name}"
  attach_external_secrets_policy                     = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["ext-external-secrets:external-secrets"]
    }
  }
  tags = local.tags
}

output "external_secrets_irsa_role_arn" {
  value = module.external_secrets_irsa_role.iam_role_arn
}
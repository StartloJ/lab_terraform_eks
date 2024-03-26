locals {
  environment    = var.environment_name
  current_region = var.aws_region

  name = local.environment

  # Mapping
  cluster_version            = var.cluster_version
  argocd_secret_manager_name = var.argocd_secret_manager_name_suffix
  eks_admin_role_name        = var.eks_admin_role_name

  tag_val_vpc            = "${local.environment}-vpc"
  tag_val_public_subnet  = "${local.tag_val_vpc}-public-"
  tag_val_private_subnet = "${local.tag_val_vpc}-private-"

  node_group_name = "managed-ondemand"

  static_tags = {
    Managed-By  = "Terraform"
    Environment = "eks-sandbox"
    Owner       = "Start"
    Project     = "container-lab"
    Cost-Center = "9999999"
    Blueprint   = local.name
    GithubRepo  = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

data "aws_caller_identity" "current" {}

resource "random_pet" "cluster" {
  length = 1
  keepers = {
    # Generate a new pet name each time we switch to a new local name
    name = local.name
  }
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.tag_val_vpc]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${local.tag_val_private_subnet}*"]
  }
}

#Add Tags for the new cluster in the VPC Subnets
resource "aws_ec2_tag" "private_subnets" {
  for_each    = toset(data.aws_subnets.private.ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.environment}-${random_pet.cluster.id}"
  value       = "shared"
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["${local.tag_val_public_subnet}*"]
  }
}

#Add Tags for the new cluster in the VPC Subnets
resource "aws_ec2_tag" "public_subnets" {
  for_each    = toset(data.aws_subnets.public.ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.environment}-${random_pet.cluster.id}"
  value       = "shared"
}

data "aws_secretsmanager_secret" "argocd" {
  name = "${local.argocd_secret_manager_name}.${local.environment}"
}

data "aws_secretsmanager_secret_version" "admin_password_version" {
  secret_id = data.aws_secretsmanager_secret.argocd.id
}

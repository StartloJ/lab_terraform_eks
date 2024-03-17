locals {
  account_name   = "watcharin"
  current_region = var.aws_region

  vpc_cidr       = var.vpc_cidr
  num_of_subnets = min(length(data.aws_availability_zones.available.names), 3)
  azs            = slice(data.aws_availability_zones.available.names, 0, local.num_of_subnets)

  argocd_secret_manager_name = var.argocd_secret_manager_name_suffix

  static_tags = {
    Managed-By  = "Terraform"
    Environment = "sandbox"
    Owner       = "Start"
    Project     = "container-lab"
    Cost-Center = "9999999"
  }
}

data "aws_availability_zones" "available" {}

resource "random_password" "argocd" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "argocd" {
  name                    = "${local.argocd_secret_manager_name}.${local.account_name}"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy

  tags = local.static_tags
}

resource "aws_secretsmanager_secret_version" "argocd" {
  secret_id     = aws_secretsmanager_secret.argocd.id
  secret_string = random_password.argocd.result
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16" #ensure to update this to the latest/desired version

  cluster_name      = module.eks_cluster.cluster_name
  cluster_endpoint  = module.eks_cluster.cluster_endpoint
  cluster_version   = module.eks_cluster.cluster_version
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller = true
  enable_kube_prometheus_stack        = true
  enable_metrics_server               = true

  enable_argocd        = true
  enable_argo_rollouts = true
  enable_argo_events   = true

  enable_ingress_nginx = false
  ingress_nginx = {
    values = [templatefile("helm_values/nginx_ingress/values.yml", {
      subnets = data.aws_subnets.public.ids
    })]
  }

  tags = local.static_tags
}
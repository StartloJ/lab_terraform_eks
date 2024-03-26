output "vpc_id" {
  value = data.aws_vpc.vpc.id
}

output "private_subnets" {
  value = toset(data.aws_subnets.private.ids)
}

output "secret_id" {
  value = data.aws_secretsmanager_secret_version.admin_password_version.id
}

output "eks_cluster_id" {
  description = "The name of the EKS cluster."
  value       = module.eks_cluster.cluster_name
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks_cluster.cluster_name}"
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "cluster_certificate_authority_data"
  value       = module.eks_cluster.cluster_certificate_authority_data
}


output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "admin_role_arn" {
  description = "ARN of the admin role granted EKS cluster admin access"
  value       = module.iam.admin_role_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if enabled"
  value       = module.eks.oidc_provider_arn
}

# output "node_iam_role_name" {
#   description = "The name of the Karpenter node IAM role"
#   value       = module.karpenter.node_iam_role_name
# }
#
# output "karpenter_queue_name" {
#   description = "Name of the Karpenter interruption SQS queue"
#   value       = module.karpenter.queue_name
# }
#
# output "karpenter_values_file" {
#   description = "Path to the generated Karpenter Helm values file"
#   value       = module.karpenter.karpenter_values_file
# }

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.networking.private_subnets
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

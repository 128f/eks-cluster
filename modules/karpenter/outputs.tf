output "node_iam_role_name" {
  description = "The name of the Karpenter node IAM role"
  value       = module.karpenter.node_iam_role_name
}

output "queue_name" {
  description = "The name of the SQS queue"
  value       = module.karpenter.queue_name
}

output "karpenter_values_file" {
  description = "Path to the generated Karpenter values file"
  value       = local_file.karpenter_values.filename
}

output "kubeconfig_file" {
  description = "Path to the generated kubeconfig file"
  value       = local_file.kubeconfig.filename
}

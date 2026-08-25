output "role_arn" {
  description = "ARN of the IAM role used by the AWS Load Balancer Controller"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "values_file" {
  description = "Path to the generated AWS Load Balancer Controller values file"
  value       = local_file.lbc_values.filename
}

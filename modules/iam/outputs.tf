output "admin_role_arn" {
  description = "ARN of the admin role granted EKS cluster admin access"
  value       = aws_iam_role.account_wide_assumable.arn
}

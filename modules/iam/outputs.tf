output "account_wide_assumable_role_arn" {
  description = "ARN of the account-wide assumable role"
  value       = aws_iam_role.account_wide_assumable.arn
}

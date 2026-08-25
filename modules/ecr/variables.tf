variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "deploy_role_name" {
  description = "Name of the IAM role (GitHub Actions deploy role) to grant push access to"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "admin_role_arn" {
  description = "ARN of the admin role for cluster access"
  type        = string
}

variable "deploy_role_arn" {
  description = "ARN of the GitHub Actions deploy role"
  type        = string
}

variable "deploy_namespace" {
  description = "Kubernetes namespace the deploy role is scoped to"
  type        = string
}

variable "create_cloudwatch_log_group" {
  description = "Whether to create the CloudWatch log group for the EKS cluster (set to false if it already exists)"
  type        = bool
  default     = true
}

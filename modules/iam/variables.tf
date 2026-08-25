variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the deploy role (e.g. org/repo)"
  type        = string
}

variable "github_repository_id" {
  description = "Immutable numeric ID of the GitHub repository allowed to assume the deploy role"
  type        = string
}

variable "github_repository_owner_id" {
  description = "Immutable numeric ID of the GitHub repository owner allowed to assume the deploy role"
  type        = string
}

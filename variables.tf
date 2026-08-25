variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "gpu-cluster"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "create_cloudwatch_log_group" {
  description = "Whether to create the CloudWatch log group for the EKS cluster (set to false if it already exists)"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "output_path" {
  description = "Path for output files"
  type        = string
}

variable "gpu_instance_types" {
  description = "Instance types for GPU node pool"
  type        = list(string)
  default     = ["g5.xlarge"]
}

variable "apps_instance_families" {
  description = "Instance families for apps node pool"
  type        = list(string)
  default     = ["m6i", "c6i", "r6i"]
}

variable "apps_capacity_limits" {
  description = "Resource limits for the apps NodePool. Defaults are conservative — raise them if you need more headroom."
  type = object({
    cpu    = number
    memory = string
  })
  default = {
    cpu    = 100
    memory = "200Gi"
  }
}

variable "gpu_capacity_limit" {
  description = "Maximum total nvidia.com/gpu across the gpu NodePool. Karpenter will not provision past this."
  type        = number
  default     = 8
}

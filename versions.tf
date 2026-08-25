terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.34"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Used only to mint the Kubernetes auth token below, via the cluster-admin
# access entry (module.iam.admin_role_arn), regardless of whether the AWS
# identity actually running Terraform has that access entry itself.
provider "aws" {
  alias  = "eks_admin"
  region = var.aws_region

  assume_role {
    role_arn = module.iam.admin_role_arn
  }
}

# Authenticates as the admin role so Terraform can manage cluster-scoped
# objects, like the otel-demo namespace, that the tightly-scoped GitHub
# Actions deploy role cannot create itself.
data "aws_eks_cluster_auth" "this" {
  provider = aws.eks_admin
  name     = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

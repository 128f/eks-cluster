# --- IAM Module -------------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  cluster_name = var.cluster_name
}

# --- Networking Module -------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  cluster_name       = var.cluster_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

# --- EKS Module -------------------------------------------------------------
module "eks" {
  source = "./modules/eks"

  cluster_name                = var.cluster_name
  kubernetes_version          = var.kubernetes_version
  vpc_id                      = module.networking.vpc_id
  private_subnets             = module.networking.private_subnets
  admin_role_arn              = module.iam.admin_role_arn
  create_cloudwatch_log_group = var.create_cloudwatch_log_group
}

# --- Karpenter Module -------------------------------------------------------------
# module "karpenter" {
#   source = "./modules/karpenter"
#
#   cluster_name                       = module.eks.cluster_name
#   cluster_endpoint                   = module.eks.cluster_endpoint
#   cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
#   aws_region                         = var.aws_region
#   output_path                        = "${path.module}/manifests"
# }

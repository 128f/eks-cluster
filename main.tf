# --- IAM Module -------------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  cluster_name               = var.cluster_name
  github_repo                = var.github_repo
  github_repository_id       = var.github_repository_id
  github_repository_owner_id = var.github_repository_owner_id
}

# --- ECR Module -------------------------------------------------------------
module "ecr" {
  source = "./modules/ecr"

  repository_name  = var.ecr_repository_name
  deploy_role_name = module.iam.deploy_role_name
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
  deploy_role_arn             = module.iam.deploy_role_arn
  deploy_namespace            = var.deploy_namespace
  create_cloudwatch_log_group = var.create_cloudwatch_log_group
}

# --- AWS Load Balancer Controller Module -------------------------------------
module "aws_lb_controller" {
  source = "./modules/aws-lb-controller"

  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  vpc_id       = module.networking.vpc_id
  output_path  = "${path.module}/manifests"

  depends_on = [module.eks]
}

# --- App namespace ------------------------------------------------------------
# Created here (via the admin access entry) because the GitHub Actions deploy
# role is namespace-scoped and cannot create Namespace objects itself.
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.deploy_namespace
  }

  depends_on = [module.eks]
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

# --- VPC -------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "gpu-vpc"

  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "gpu-vpc"
  }

  public_subnet_tags = {
    "karpenter.sh/discovery" = "${var.cluster_name}-public"
  }

  private_subnet_tags = {
    "karpenter.sh/discovery" = "${var.cluster_name}-private"
  }
}

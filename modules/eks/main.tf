# --- EKS cluster -------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  authentication_mode = "API_AND_CONFIG_MAP"

  endpoint_public_access = true

  eks_managed_node_groups = {
    bootstrap = {
      name           = "bootstrap"
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      min_size     = 2
      max_size     = 5
      desired_size = 3

      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }
    }
  }

  access_entries = {
    admin = {
      principal_arn = var.admin_role_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Addons required by Karpenter
  addons = {
    coredns                = {}
    eks-pod-identity-agent = { before_compute = true }
    vpc-cni                = { before_compute = true }
    kube-proxy             = {}
  }

  # Tag subnets / SG for Karpenter auto-discovery
  tags = { "karpenter.sh/discovery" = var.cluster_name }
}

resource "local_file" "kubeconfig" {
  filename = "${var.output_path}/kubeconfig.yaml"
  content  = <<EOT
apiVersion: v1
clusters:
- cluster:
    server: ${module.eks.cluster_endpoint}
    certificate-authority-data: ${module.eks.cluster_certificate_authority_data}
  name: ${var.cluster_name}
contexts:
- context:
    cluster: ${var.cluster_name}
    user: aws
  name: ${var.cluster_name}
current-context: ${var.cluster_name}
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1
      command: aws
      interactiveMode: Never
      args:
        - eks
        - get-token
        - --region
        - ${var.aws_region}
        - --role-arn
        - ${var.admin_role_arn}
        - --cluster-name
        - ${var.cluster_name}
EOT
}

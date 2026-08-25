data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# --- Admin Role -------------------------------------------------------------
resource "aws_iam_role" "account_wide_assumable" {
  name = "account-wide-eks-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# --- GitHub Actions OIDC Provider -------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ab9d0263244dd0326eb67015705a667e79cfe998"]
}

# --- Deploy Role (assumed by GitHub Actions via OIDC) -----------------------
resource "aws_iam_role" "deploy" {
  name = "${var.cluster_name}-gha-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud"                 = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:repository_id"       = var.github_repository_id
            "token.actions.githubusercontent.com:repository_owner_id" = var.github_repository_owner_id
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${split("/", var.github_repo)[0]}@${var.github_repository_owner_id}/${split("/", var.github_repo)[1]}@${var.github_repository_id}:*"
          }
        }
      }
    ]
  })
}

# --- Allow the deploy role to look up the EKS cluster ------------------------
resource "aws_iam_role_policy" "deploy_eks_describe" {
  name = "${var.cluster_name}-eks-describe"
  role = aws_iam_role.deploy.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "eks:DescribeCluster",
        Resource = "arn:aws:eks:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

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

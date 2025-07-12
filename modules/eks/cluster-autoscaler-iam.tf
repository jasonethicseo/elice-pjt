# Cluster Autoscaler IAM Role
resource "aws_iam_role" "cluster_autoscaler_role" {
  count = var.enable_cluster_autoscaler ? 1 : 0
  
  name = "eks-cluster-autoscaler-role-${var.stage}-${var.servicename}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
            "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Cluster Autoscaler IAM Policy
resource "aws_iam_policy" "cluster_autoscaler_policy" {
  count = var.enable_cluster_autoscaler ? 1 : 0
  
  name        = "eks-cluster-autoscaler-policy-${var.stage}-${var.servicename}"
  description = "Policy for Cluster Autoscaler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attach" {
  count = var.enable_cluster_autoscaler ? 1 : 0
  
  role       = aws_iam_role.cluster_autoscaler_role[0].name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy[0].arn
}
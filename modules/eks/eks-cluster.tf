resource "aws_eks_cluster" "eks-cluster" {

  enabled_cluster_log_types = ["api", "audit"]

  name     = "aws-eks-cluster-${var.stage}-${var.servicename}"
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.sg-eks-cluster.id]
  }
  # encryption_config {
  #   provider {
  #     key_arn = var.eks_kms_key_id
  #   }
  #   resources = ["secrets"]

  # }
  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-role-attachment-clusterpolicy,
    aws_iam_role_policy_attachment.eks-cluster-role-attachment-vpccontroller,
    aws_cloudwatch_log_group.ekscluster-cluster-log-group,
    aws_security_group.sg-eks-cluster
  ]
  tags = var.tags
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer

  tags = var.tags
}


resource "aws_cloudwatch_log_group" "ekscluster-cluster-log-group" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/aws-eks-${var.stage}-${var.servicename}/cluster"
  retention_in_days = 7

  # ... potentially other configuration ...
}

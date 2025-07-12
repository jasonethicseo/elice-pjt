output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}
output "eks_cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

output "sg_eks_cluster_id" {
  value = aws_security_group.sg-eks-cluster.id
}

output "eks_node_sg_id" {
  value = aws_security_group.sg-eks-node.id
}
output "eks_node_role_arn" {
  value = aws_iam_role.eks-node-role.arn
}
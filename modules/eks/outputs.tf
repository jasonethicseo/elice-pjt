output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "cluster_id" {
  value = aws_eks_cluster.eks-cluster.id
}

output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
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

output "node_group_arn" {
  value = aws_eks_node_group.eks-node-group.arn
}
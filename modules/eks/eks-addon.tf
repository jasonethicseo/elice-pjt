resource "aws_eks_addon" "eks-addon-vpc-cni" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "vpc-cni"
  depends_on = [aws_eks_cluster.eks-cluster]
}
resource "aws_eks_addon" "eks-addon-coreDNS" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "coredns"
  depends_on = [aws_eks_cluster.eks-cluster,
              aws_eks_node_group.eks-node-group]
}
resource "aws_eks_addon" "eks-addon-kubeproxy" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "kube-proxy"
  depends_on = [aws_eks_cluster.eks-cluster]
}
resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name_prefix = "aws-eks-node-group-${var.stage}-${var.servicename}"
  node_role_arn   = aws_iam_role.eks-node-role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size 
    max_size     = var.max_size
    min_size     = var.min_size
  }

  #update_config {
  #  max_unavailable = var.max_unavailable
  #}
  
  ami_type = var.ami_type
  instance_types       = var.instance_types
  capacity_type = var.capacity_type
  force_update_version = var.force_update_version
  labels = var.labels
  launch_template {
    id      = aws_launch_template.workers_launch_template.id
    version = aws_launch_template.workers_launch_template.latest_version
  }
  tags = var.tags


  lifecycle {
    create_before_destroy = true
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}


#resource "aws_autoscaling_policy" "node_group_policy" {
#  name                   = "aws-eks-node-group-policy-${var.stage}-${var.servicename}"
#  autoscaling_group_name = aws_eks_node_group.eks-node-group.resources.0.autoscaling_groups.0.name
#  policy_type            = "TargetTrackingScaling"
#  target_tracking_configuration {
#    predefined_metric_specification {
#      predefined_metric_type = "ASGAverageCPUUtilization"
#     }
#    target_value = 80.0
#  }
#  depends_on = [aws_eks_node_group.eks-node-group]
#}

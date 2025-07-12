# EKS cluster security group
resource "aws_security_group" "sg-eks-cluster" {
  name   = "aws-sg-${var.stage}-${var.servicename}-eks-cluster"
  vpc_id = var.network_vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = var.sg_eks_cluster_ingress_list
    security_groups = [aws_security_group.sg-eks-node.id]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = var.sg_eks_cluster_ingress_list
    security_groups = [aws_security_group.sg-eks-node.id]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({
        Name = "aws-sg-${var.stage}-${var.servicename}-eks-cluster",
        "kubernetes.io/cluster/aws-eks-cluster-${var.stage}-${var.servicename}" = "owned"}),
        var.tags)
  depends_on =[aws_security_group.sg-eks-node]
}

# EKS Node security group
resource "aws_security_group" "sg-eks-node" {
  name   = "aws-sg-${var.stage}-${var.servicename}-eks-node"
  vpc_id = var.network_vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = var.sg_eks_cluster_ingress_list
  }
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "TCP"
    cidr_blocks = var.sg_eks_cluster_ingress_list
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "TCP"
    cidr_blocks = var.sg_eks_cluster_ingress_list
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "UDP"
    cidr_blocks = var.sg_eks_cluster_ingress_list
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    self        = true
  }  
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({
        Name = "aws-sg-${var.stage}-${var.servicename}-eks-node",
        "kubernetes.io/cluster/aws-eks-cluster-${var.stage}-${var.servicename}" = "owned"}),
        var.tags)

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ingress]
  }
}


#ELB Security group
# resource "aws_security_group" "sg-int-elb" {
#   name   = "aws-sg-${var.stage}-${var.servicename}-int-elb"
#   vpc_id = var.network_vpc_id
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "TCP"
#     cidr_blocks = var.sg_eks_cluster_ingress_list
#   }
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "TCP"
#     cidr_blocks = var.sg_eks_cluster_ingress_list
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = merge(tomap({
#         Name = "aws-sg-${var.stage}-${var.servicename}-int-elb"}), 
#         var.tags)
# }

# 임시 aws ingress controller용 9443 포트 인바운드 오픈
resource "aws_security_group_rule" "eks-node-9443" {
  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg-eks-cluster.id
  security_group_id        = aws_security_group.sg-eks-node.id
  description              = "Allow inbound 9443 from cluster to node"
  depends_on = [
    aws_security_group.sg-eks-node,
    aws_security_group.sg-eks-cluster
  ]
}


resource "aws_security_group_rule" "eks-node-443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg-eks-cluster.id
  security_group_id        = aws_security_group.sg-eks-node.id
  description              = ""
  depends_on =[aws_security_group.sg-eks-node, aws_security_group.sg-eks-cluster] 
}
resource "aws_security_group_rule" "eks-node-4443-cluster" {
  type                     = "ingress"
  from_port                = 4443
  to_port                  = 4443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg-eks-cluster.id
  security_group_id        = aws_security_group.sg-eks-node.id
  description              = ""
  depends_on =[aws_security_group.sg-eks-node, aws_security_group.sg-eks-cluster]
}
resource "aws_security_group_rule" "eks-node-10250" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg-eks-cluster.id
  security_group_id        = aws_security_group.sg-eks-node.id
  description              = ""
  depends_on =[aws_security_group.sg-eks-node, aws_security_group.sg-eks-cluster]
}
resource "aws_security_group_rule" "eks-node-443-self" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg-eks-node.id
  security_group_id        = aws_security_group.sg-eks-node.id
  description              = ""
  depends_on =[aws_security_group.sg-eks-node]
}
resource "aws_security_group_rule" "eks-node-53-tcp-self" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg-eks-node.id
  security_group_id        = aws_security_group.sg-eks-node.id
  description              = ""
  depends_on =[aws_security_group.sg-eks-node]
}
resource "aws_security_group_rule" "eks-node-53-udp-self" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  source_security_group_id = aws_security_group.sg-eks-node.id
  security_group_id        = aws_security_group.sg-eks-node.id
  description              = ""
  depends_on =[aws_security_group.sg-eks-node]
}

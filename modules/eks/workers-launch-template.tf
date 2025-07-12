# Node grroup launch template
## userdata
data "cloudinit_config" "workers_userdata" {
  gzip          = false
  base64_encode = true
  boundary      = "//"

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/userdata.sh.tpl",
      {
        cluster_name         = aws_eks_cluster.eks-cluster.id
        cluster_endpoint     = aws_eks_cluster.eks-cluster.endpoint
        cluster_auth_base64  = aws_eks_cluster.eks-cluster.certificate_authority.0.data
      }
    )
  }
}


# launch template
resource "aws_launch_template" "workers_launch_template" {
  name_prefix   = "aws-node-${var.stage}-${var.servicename}"
#  instance_type = element(var.instance_types, 0) 

  update_default_version = true
#  block_device_mappings {
#    device_name = "/dev/xvda"

#    ebs {
#      volume_size           = var.disk_size
#      encrypted             = true
#      kms_key_id            = var.disk_kms_key_id
#      delete_on_termination = true
#    }
#  }
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups = [aws_security_group.sg-eks-node.id]
  }

#  user_data = data.cloudinit_config.workers_userdata.rendered
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "aws-node-${var.stage}-${var.servicename}"
      })
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.tags,
      {
        Name = "aws-node-vol-${var.stage}-${var.servicename}"
      })
  }

  # Supplying custom tags to EKS instances ENI's is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "network-interface"
    tags = merge(
      var.tags,
      {
        Name = "aws-node-eni-${var.stage}-${var.servicename}"
      })
  }
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }

  # Prevent premature access of security group roles and policies by pods that
  # require permissions on create/destroy that depend on workers.
  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_security_group.sg-eks-node,
    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-node-role-attachment-fluentbit-policy
  ]
}


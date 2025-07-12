resource "aws_security_group" "ecs_sg_external" {
  count       = var.create_alb ? 1 : 0
  name        = "aws-sg-${var.prefix_name}-alb-ext"
  description = "Allow Access to ECS Cluster"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "TCP"
    cidr_blocks = [for s in data.aws_subnet.alb_subnets_cidrs : s.cidr_block]
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "TCP"
    cidr_blocks = var.whitelist_ips
  }
  ingress {
    from_port   = var.alb_listener_port
    to_port     = var.alb_listener_port
    protocol    = "TCP"
    cidr_blocks = [for s in data.aws_subnet.alb_subnets_cidrs : s.cidr_block]
  }
  ingress {
    from_port   = var.alb_listener_port
    to_port     = var.alb_listener_port
    protocol    = "TCP"
    cidr_blocks = var.whitelist_ips
  }
  egress {
    from_port   = var.ecs_container_port
    to_port     = var.ecs_container_port
    protocol    = "TCP"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  tags = merge(var.tags, {
    Name         = "aws-sg-${var.prefix_name}-alb-ext"
  })
}

resource "aws_security_group" "ecs_sg_internal" {
  name        = "aws-sg-${var.prefix_name}-ecs-int"
  description = "Allow Access to ECS Cluster"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = var.ecs_container_port
    to_port     = var.ecs_container_port
    protocol    = "TCP"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, {
    Name         = "aws-sg-${var.prefix_name}-ecs-int"
  })
}



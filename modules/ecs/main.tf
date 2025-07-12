resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.cluster_name
  capacity_providers = var.ecs_is_fargate ? ["FARGATE"] : [ aws_ecs_capacity_provider.ecs_capacity_provider[0].name ]
  default_capacity_provider_strategy {
     capacity_provider = var.ecs_is_fargate ? "FARGATE" : aws_ecs_capacity_provider.ecs_capacity_provider[0].name
   }

  setting {
    name  = "containerInsights"
    value = var.ecs_containerInsights
  }
  tags = merge(var.tags, {
    Name         = local.cluster_name
  })
}

locals {
  vpc_id         = var.vpc_id
  cluster_name   = "aws-ecs-${var.prefix_name}"
  volume_name    = "${var.prefix_name}_volume"
  timestamp      = formatdate("YYYYMMDDhhmmss", timestamp())
}

data "aws_vpc" "selected" {
  id = local.vpc_id
}

data "aws_subnet" "alb_subnets_cidrs" {
  for_each = { for s in var.alb_subnets : s => s }
  id       = each.value
}

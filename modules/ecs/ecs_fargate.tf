resource "aws_ecs_task_definition" "ecs_task_definition_for_fargate" {
  count                    = var.ecs_is_fargate ? 1 : 0
  family                   = "aws-tdn-${var.prefix_name}"
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.ecs_task.rendered
  tags = merge(var.tags, {
    Name         = "aws-tdn-${var.prefix_name}"
  })
}

resource "aws_ecs_service" "ecs_service_for_fargate" {
  # platform_version                   = "1.4.0"
  count                              = var.ecs_is_fargate && var.ecs_needs_service ? 1 : 0
  name                               = "aws-svc-${var.prefix_name}"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.ecs_task_definition_for_fargate[count.index].arn
  launch_type                        = "FARGATE"
  desired_count                      = var.ecs_desired_count
  deployment_minimum_healthy_percent = var.ecs_deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.ecs_deployment_maximum_percent
  propagate_tags                     = "TASK_DEFINITION"
  health_check_grace_period_seconds  = 0
  enable_execute_command = var.enable_execute_command
  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg_internal.id]
    subnets          = var.ecs_subnets
    assign_public_ip = false
  }
  
  tags = merge(var.tags, {
    Name         = "aws-svc-${var.prefix_name}"
  })
  depends_on = [aws_ecs_task_definition.ecs_task_definition_for_fargate]
}

resource "aws_iam_role" "ecs_autoscale_role" {
  count              = var.ecs_is_fargate && var.ecs_needs_service ? 1 : 0
  name               = "aws-role-${var.prefix_name}-for-as"
  assume_role_policy = file("${path.module}/policies/ecs_autoscale_iam_role.json")
  tags = merge(var.tags, {
    Name         = "aws-role-${var.prefix_name}-for-as"
  })
}

resource "aws_iam_policy" "ecs_autoscale_role_policy" {
  count  = var.ecs_is_fargate && var.ecs_needs_service ? 1 : 0
  name   = "aws-iam-plc-${var.prefix_name}-as"
  policy = file("${path.module}/policies/ecs_autoscale_iam_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale_role_policy_attach" {
  count      = var.ecs_is_fargate && var.ecs_needs_service ? 1 : 0
  role       = aws_iam_role.ecs_autoscale_role[count.index].id
  policy_arn = aws_iam_policy.ecs_autoscale_role_policy[count.index].arn
}




resource "aws_ecs_task_definition" "ecs_task_definition_for_ec2" {
  count                 = var.ecs_is_fargate ? 0 : 1
  family                = "aws-tdn-${var.prefix_name}"
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  cpu                   = var.ecs_task_cpu
  memory                = var.ecs_task_memory
  container_definitions = data.template_file.ecs_task.rendered
  volume {
    name = local.volume_name
    docker_volume_configuration {
      driver        = "cloudstor:aws"
      scope         = "shared"
      autoprovision = true
      driver_opts = {
        "ebstype" = "gp2"
        "size"    = var.ecs_ec2_volume_size
        "backing" = "relocatable"
      }
    }
  }
  volume {
    name      = "docker_sock"
    host_path = "/var/run/docker.sock"
  }
  tags = merge(var.tags, {
    Name         = "aws-tdn-${var.prefix_name}"
  })
}

resource "aws_ecs_service" "ecs_service_for_ec2" {
  count                              = !var.ecs_is_fargate && var.ecs_needs_service ? 1 : 0
  name                               = "aws-svc-${var.prefix_name}"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.ecs_task_definition_for_ec2[count.index].arn
  desired_count                      = var.ecs_desired_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  load_balancer {
    target_group_arn = var.create_alb ? aws_lb_target_group.ecs_target_group_external[0].arn : null
    container_port   = var.create_alb ? var.ecs_container_port : null
    container_name   = var.create_alb ? var.ecs_container_name : null
  }
  tags = merge(var.tags, {
    Name         = "aws-svc-${var.prefix_name}"
  })
  depends_on = [aws_ecs_task_definition.ecs_task_definition_for_fargate]
}

resource "aws_launch_configuration" "ecs_ec2_launch_configuration" {
  count                = var.ecs_is_fargate ? 0 : 1
  name_prefix          = "aws-launch-config-${var.prefix_name}-"
  image_id             = var.ecs_ec2_instance_ami
  instance_type        = var.ecs_ec2_type
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile[0].name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.ecs_ec2_volume_size
    delete_on_termination = "true"
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups = [aws_security_group.ecs_sg_external[0].id]
  key_name        = var.ecs_ec2_key_pair_name
  user_data       = data.template_file.ec2_user_data.rendered
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  count                = var.ecs_is_fargate ? 0 : 1
  name_prefix          = "aws-asg-${var.prefix_name}-"
  max_size             = 1
  min_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = var.ecs_subnets
  launch_configuration = aws_launch_configuration.ecs_ec2_launch_configuration[count.index].name
  tag {
    key                 = "Name"
    value               = "aws-asg-${var.prefix_name}"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  count = var.ecs_is_fargate ? 0 : 1
  name  = "aws-cp-${var.prefix_name}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_autoscaling_group[0].arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}
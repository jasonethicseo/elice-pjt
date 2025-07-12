resource "aws_lb" "ecs_load_balancer_external" {
  count                      = var.create_alb ? 1 : 0
  name                       = "aws-alb-${var.prefix_name}-ext"
  security_groups            = [aws_security_group.ecs_sg_external[0].id]
  subnets                    = var.alb_subnets
  internal                   = var.alb_internal
  enable_deletion_protection = var.alb_deletion_protection
  idle_timeout               = var.alb_idle_timeout

  access_logs {
    bucket  = var.alb_logging_bucket_id
    enabled = "true"
  }

  tags = merge(var.tags, {
    Name         = "aws-alb-${var.prefix_name}-ext"
  })
}

resource "aws_lb_listener" "ecs_alb_listener_80" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.ecs_load_balancer_external[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "ecs_alb_listener" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.ecs_load_balancer_external[0].arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol
  ssl_policy        = var.alb_ssl_policy
  certificate_arn   = var.acm_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Health OK"
      status_code  = "200"
    }
  }
}

resource "aws_lb_target_group" "ecs_target_group_external" {
  count                         = var.create_alb ? 1 : 0
  name                          = "aws-tg-${var.prefix_name}"
  protocol                      = "HTTP"
  target_type                   = var.ecs_is_fargate ? "ip" : "instance"
  port                          = var.ecs_container_port
  vpc_id                        = local.vpc_id
  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    healthy_threshold   = var.alb_target_group_health_check["healthy_threshold"]
    unhealthy_threshold = var.alb_target_group_health_check["unhealthy_threshold"]
    timeout             = var.alb_target_group_health_check["timeout"]
    interval            = var.alb_target_group_health_check["interval"]
    matcher             = var.alb_target_group_health_check["matcher"]
    path                = var.alb_target_group_health_check["path"]
    port                = var.alb_target_group_health_check["port"]
    protocol            = var.alb_target_group_health_check["protocol"]
  }
  stickiness {
    enabled         = var.alb_stickiness_enabled
    type            = "lb_cookie"
    cookie_duration = 86400 # 1 day
  }
  tags = merge(var.tags, {
    Name         = "aws-tg-${var.prefix_name}"
  })
  depends_on = [aws_lb_listener.ecs_alb_listener]
}

resource "aws_lb_listener_rule" "ecs_alb_listener_rule" {
  count        = var.create_alb ? 1 : 0
  listener_arn = aws_lb_listener.ecs_alb_listener[0].arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group_external[0].arn
  }

  # condition {
  #   host_header {
  #     values = [var.domain_name]
  #   }
  # }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_route53_record" "ecs_route53_record" {
  for_each        = toset(var.hosted_zone_ids)
  zone_id         = each.value
  name            = var.domain_name
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_lb.ecs_load_balancer_external[0].dns_name
    zone_id                = aws_lb.ecs_load_balancer_external[0].zone_id
    evaluate_target_health = false
  }
}

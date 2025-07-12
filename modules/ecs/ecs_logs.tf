resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "aws-loggroup-${var.prefix_name}-ecs"
  retention_in_days = var.cloudwatch_log_retention_days
  tags = merge(var.tags, {
    Name         = "aws-loggroup-${var.prefix_name}-ecs"
  })
}

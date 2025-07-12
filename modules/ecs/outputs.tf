output "ecs_cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.ecs_cluster.id
}
output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = local.cluster_name
}
output "ecs_autoscale_role_for_fargate" {
  description = "ecs autoscale role for fargate"
  value       = var.ecs_is_fargate && var.ecs_needs_service ? aws_iam_role.ecs_autoscale_role[0].arn : ""
}
output "ecs_task_iam_arn" {
  description = "Task IAM arn"
  value       = aws_iam_role.ecs_task_role.arn
}
output "ecs_task_iam_name" {
  description = "Task IAM name"
  value       = aws_iam_role.ecs_task_role.name
}
output "ecs_sg_internal_id" {
  description = "ID of internal ecs security group"
  value       = aws_security_group.ecs_sg_internal.id
}
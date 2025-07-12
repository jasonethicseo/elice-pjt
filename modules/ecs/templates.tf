data "template_file" "ec2_user_data" {
  template = "${file("${path.module}/user_data/ec2_user_data.sh")}"

  vars = {
    cluster_name = local.cluster_name
    region       = var.aws_region
  }
}

data "template_file" "ecs_task" {
  template = var.ecs_is_fargate ? file("${path.module}/container_definitions/ecs_task_definition_fargate") : file("${path.module}/container_definitions/ecs_task_definition")

  vars = {
    container_name              = var.ecs_container_name
    container_port              = var.ecs_container_port
    aws_region                  = var.aws_region
    log_group                   = aws_cloudwatch_log_group.cloudwatch_log_group.id
    ecr_uri                     = var.ecs_task_image_uri
    volume_mount_container_path = "/tmp"
    volume_name                 = local.volume_name
    volume_container_path       = var.ecs_ec2_volume_container_path
    ecs_environment             = var.ecs_environment
    ecs_secrets                 = var.ecs_secrets
    ecs_container_cpu           = var.ecs_container_cpu
    ecs_container_memory        = var.ecs_container_memory
  }
}

data "template_file" "ecs_role_ebs" {
  template = file("${path.module}/policies/ecs_role_ebs.json")
}

data "template_file" "ecs_task_role_policy" {
  template = file("${path.module}/policies/ecs_task_role_policy.json")
  vars = {
    region                = var.aws_region
    aws_account_id        = data.aws_caller_identity.current.account_id
    log_group_arn         = aws_cloudwatch_log_group.cloudwatch_log_group.arn
    ecs_cluster_name      = aws_ecs_cluster.ecs_cluster.name
    s3_kms_key            = var.s3_kms_key
    ssm_parameter_kms_key = var.ssm_parameter_kms_key
  }
}

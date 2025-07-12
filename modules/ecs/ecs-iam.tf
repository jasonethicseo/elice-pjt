resource "aws_iam_role" "ecs_task_role" {
  name               = "aws-role-${var.prefix_name}-ecs-task"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  tags = merge(var.tags, {
    Name         = "aws-role-${var.prefix_name}-ecs-task"
  })
}

resource "aws_iam_policy" "ecs_task_policy" {
  name   = "aws-iam-plc-ecs-task-${var.prefix_name}"
  policy = data.template_file.ecs_task_role_policy.rendered
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attach" {
  role       = aws_iam_role.ecs_task_role.id
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

resource "aws_iam_role" "ec2_role" {
  count              = var.ecs_is_fargate ? 0 : 1
  name               = "aws-role-${var.prefix_name}-ec2"
  assume_role_policy = file("${path.module}/policies/ecs-assume-role.json")
  tags = merge(var.tags, {
    Name         = "aws-role-${var.prefix_name}-ec2"
  })
}

resource "aws_iam_policy" "ecs_role_ebs_policy" {
  count  = var.ecs_is_fargate ? 0 : 1
  name   = "aws-iam-plc-ecs-ebs-${var.prefix_name}"
  policy = data.template_file.ecs_role_ebs.rendered
}

resource "aws_iam_role_policy_attachment" "ecs_role_ebs_policy_attach" {
  count      = var.ecs_is_fargate ? 0 : 1
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = aws_iam_policy.ecs_role_ebs_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "ssm_session_manager_policy_attach" {
  count      = var.ecs_is_fargate ? 0 : 1
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ecs_service_policy_attach" {
  count      = var.ecs_is_fargate ? 0 : 1
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_policy_attach" {
  count      = var.ecs_is_fargate ? 0 : 1
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecr_policy_attach" {
  count      = var.ecs_is_fargate ? 0 : 1
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  count      = var.ecs_is_fargate ? 0 : 1
  name = "ecsInstanceProfileFor${var.prefix_name}"
  path = "/"
  role = aws_iam_role.ec2_role[0].name
}

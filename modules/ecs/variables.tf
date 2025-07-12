data "aws_caller_identity" "current" {}

variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}
variable "whitelist_ips" { 
  type = list
  default = []
 }
variable "prefix_name" { type = string }
variable "vpc_id" { type = string }
variable "ecs_subnets" {}
variable "alb_subnets" {
  default = []
}
variable "acm_arn" { 
  type = string 
  default = ""
}
variable "domain_name" { 
  type = string
  default = "" 
}
variable "hosted_zone_ids" { 
  type = list 
  default = []
}
variable "tags" { type = map(string) }

### ALB
variable "create_alb" {
  type    = bool
  default = true
}
variable "alb_arn" {
  type    = string
  default = null
}
variable "alb_logging_bucket_id" {
  type = string 
  default = ""
}
variable "alb_internal" {
  type    = bool
  default = false
}
variable "alb_listener_port" {
  type    = string
  default = "443"
}
variable "alb_listener_protocol" {
  type    = string
  default = "HTTPS"
}
variable "alb_deletion_protection" {
  type    = bool
  default = false
}
variable "alb_stickiness_enabled" {
  type    = bool
  default = false
}
variable "alb_idle_timeout" {
  type    = string
  default = "600"
}
variable "alb_ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-2016-08"
}
### ECS
variable "ecs_environment" {
  type    = string
  default = ""
}
variable "ecs_secrets" {
  type    = string
  default = ""
}
variable "ecs_is_fargate" {
  type    = bool
  default = true
}
variable "ecs_needs_service" {
  type    = bool
  default = true
}
variable "ecs_container_name" {
  type    = string
}
variable "ecs_container_port" {
  type    = string
  default = "8080"
}
variable "ecs_task_cpu" {
  type    = string
  default = "256"
}
variable "ecs_task_memory" {
  type    = string
  default = "512"
}
variable "ecs_container_cpu" {
  type    = string
  default = "256"
}
variable "ecs_container_memory" {
  type    = string
  default = "512"
}
variable "ecs_desired_count" {
  type    = number
  default = 1
}
variable "ecs_deployment_minimum_healthy_percent" {
  type    = string
  default = "100"
}
variable "ecs_deployment_maximum_percent" {
  type    = string
  default = "200"
}
variable "ecs_task_image_uri" {
  type    = string
  default = ""
}
variable "ecs_containerInsights" {
  type    = string
  default = "disabled"
}
variable "ecs_ec2_instance_ami" {
  type    = string
  default = "ami-0accbb5aa909be7bf" #ap-northeast-2
}
variable "ecs_ec2_type" {
  type    = string
  default = "ami-0accbb5aa909be7bf" #ap-northeast-2
}
variable "ecs_ec2_volume_size" {
  type    = string
  default = "40"
}
variable "ecs_ec2_volume_container_path" {
  type    = string
  default = "/usr/local/volume"
}
variable "ecs_ec2_key_pair_name" {
  type    = string
  default = ""
}
variable "alb_target_group_health_check" {
  type = map(string)
  default = {
    healthy_threshold   = "2"
    unhealthy_threshold = "5"
    timeout             = "20"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}
variable "cloudwatch_log_retention_days" {
  type = number
  default = 90
}
variable "s3_kms_key" {
  type = string
}
variable "ssm_parameter_kms_key" {
  type = string
}
variable "enable_execute_command" {
  type = bool
  default = true
}
####################################
# Outputs
####################################
output "vpc_id" {
  value = module.vpc.vpc_id
}

# output "ec2_ids" {
#   value = module.instance.instance_id
# }


# output "alb_dns_name" {
#   value = module.alb.alb_dns_name
# }

output "aurora_endpoint" {
  value = module.aurora.endpoint
}

output "aurora_ro_endpoint" {
  value = module.aurora.ro_endpoint
}

# --- !!! 기존 비밀번호 출력 제거 또는 주석 처리 !!! ---
# output "aurora_db_password" { # [Source 1] 제거 또는 주석 처리
#   value = module.aurora.rds_random-password
#   sensitive = true
# }

# --- !!! Secrets Manager 관련 출력 추가 !!! ---
output "aurora_db_password_secret_arn" {
  description = "ARN of the Secrets Manager secret for the Aurora password"
  value       = module.aurora.db_password_secret_arn
  # ARN 자체는 민감 정보가 아니므로 sensitive 불필요
}

output "aurora_db_password_secret_name" {
  description = "Name of the Secrets Manager secret for the Aurora password"
  value       = module.aurora.db_password_secret_name
  # Secret 이름 자체는 민감 정보가 아니므로 sensitive 불필요
}


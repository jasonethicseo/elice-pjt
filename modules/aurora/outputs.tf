# --- !!! 기존 비밀번호 출력 제거 !!! ---
# output "rds-random-password" { # [Source 255] 제거 대상
#   value     = random_password.rds_password.result
#   sensitive = true
# }

# --- !!! Secrets Manager 관련 출력 추가 !!! ---
output "db_password_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the master password."
  value       = aws_secretsmanager_secret.aurora_db_password_secret.arn
}

output "db_password_secret_name" {
  description = "Name of the Secrets Manager secret containing the master password."
  value       = aws_secretsmanager_secret.aurora_db_password_secret.name
}


output "endpoint" {
  value     = aws_rds_cluster.rds-cluster.endpoint
}
output "ro_endpoint" {
  value     = aws_rds_cluster.rds-cluster.reader_endpoint
}
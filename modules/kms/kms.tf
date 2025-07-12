# resource "aws_kms_key" "rds-kms-key" {
#   description             = "This key is used to encrypt rds ${var.stage}-${var.servicename}"
#   enable_key_rotation     = true
#   deletion_window_in_days = 10
#   tags = merge(tomap({
#          Name = "aws-kms-${var.stage}-${var.servicename}-rds"}),
#          var.tags)
# }

# 새로 추가: EBS 볼륨 암호화용 KMS 키
resource "aws_kms_key" "ebs-kms-key" {
  description             = "This key is used to encrypt EBS volumes for ${var.stage}-${var.servicename}"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  tags = merge(tomap({
         Name = "aws-kms-${var.stage}-${var.servicename}-ebs"
  }), var.tags)
}

resource "aws_kms_alias" "ebs-comm-kms-key-alias" {
  name          = "alias/aws-kms-${var.stage}-${var.servicename}-ebs"
  target_key_id = aws_kms_key.ebs-kms-key.key_id
}

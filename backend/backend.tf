provider "aws" {
  region = "ca-central-1"
}

resource "aws_s3_bucket" "terraform_state" { 
    bucket = "jasonseo-dev-terraform-state"
}

resource "aws_s3_bucket_versioning" "enabled" { 
    bucket = aws_s3_bucket.terraform_state.id 
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.terraform_state.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_lock" {
    name = "jasonseo-dev-terraform-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}
resource "aws_ecr_repository" "ecr-repository" {
  for_each             = toset(var.ecr_repository_list)
  name                 = "aws-ecr-${var.stage}-${var.servicename}-${each.key}"
  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.image_scan_on_push
  }
  tags = merge(tomap({
         Name =  "aws-ecr-${var.stage}-${var.servicename}-${each.key}"}),
        var.tags)
}
data "aws_iam_policy_document" "ecr-repository-policy" {
  statement {
    sid    = "AllowPull"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.ecr_allow_account_arns
    }
    actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
    ]
  }
}
resource "aws_ecr_repository_policy" "ecr-policy" {
  for_each   = toset(var.ecr_repository_list)
  repository = "aws-ecr-${var.stage}-${var.servicename}-${each.key}"
  depends_on = [aws_ecr_repository.ecr-repository]
  policy     = data.aws_iam_policy_document.ecr-repository-policy.json
}

resource "aws_ecr_lifecycle_policy" "ecr-lifecycle-policy" {
  for_each   = toset(var.ecr_repository_list)
  repository = "aws-ecr-${var.stage}-${var.servicename}-${each.key}"
  depends_on = [aws_ecr_repository.ecr-repository]
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 30 ${var.stage} images",
      "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["${var.stage}-"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
      },
      "action": {
          "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep FEATURE images for 14 days",
      "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["feature"],
          "countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 14
      },
      "action": {
          "type": "expire"
      }
    },
    {
      "rulePriority": 3,
      "description": "Keep MR images for 14 days",
      "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["mr"],
          "countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 14
      },
      "action": {
          "type": "expire"
      }
    },
    {
      "rulePriority": 4,
      "description": "Keep BUGFIX images for 14 days",
      "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["bugfix"],
          "countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 14
      },
      "action": {
          "type": "expire"
      }
    },
    {
      "rulePriority": 5,
      "description": "Keep HOTFIX images for 14 days",
      "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["hotfix"],
          "countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 14
      },
      "action": {
          "type": "expire"
      }
    }
  ]
}
EOF
}

## helm ecr
resource "aws_ecr_repository" "helm-repository" {
  count                = var.isdev ? 1 : 0 ##create if true(only dev, not stg, prd)
  name                 = "aws-ecr-${var.stage}-${var.servicename}-${var.helm_repository}"
  image_tag_mutability = var.image_tag_mutability
  tags = merge(tomap({
         Name =  "aws-ecr-${var.stage}-${var.servicename}-${var.helm_repository}"}),
        var.tags)
}
resource "aws_ecr_repository_policy" "helm-ecr-policy" {
  count      = var.isdev ? 1 : 0 ##create if true(only dev, not stg, prd)
  repository = "aws-ecr-${var.stage}-${var.servicename}-${var.helm_repository}"
  depends_on = [aws_ecr_repository.helm-repository]
  policy     = data.aws_iam_policy_document.ecr-repository-policy.json
}

resource "aws_ecr_lifecycle_policy" "helm-ecr-lifecycle-policy" {
  count      = var.isdev ? 1 : 0 ##create if true(only dev, not stg, prd)
  repository = "aws-ecr-${var.stage}-${var.servicename}-${var.helm_repository}"
  depends_on = [aws_ecr_repository.helm-repository]
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 30 images",
      "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["${var.stage}-"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
      },
      "action": {
          "type": "expire"
      }
    }
  ]
}
EOF
}

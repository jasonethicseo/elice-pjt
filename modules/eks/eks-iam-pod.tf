# IAM Roles for K8S Service Accounts
## Service account will be [moga, admin, batch, data, kaniko, crm, autoscaling]
data "tls_certificate" "cert" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc-provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
  depends_on = [aws_eks_cluster.eks-cluster]
}

#####moga
# resource "aws_iam_role" "eks-moga-acc-role" {
#   assume_role_policy = data.aws_iam_policy_document.moga-eks-assume-role-policy.json
#   name               = upper("aws-iam-eks-moga-acc-role")
#   max_session_duration = 43200
#   depends_on =[aws_iam_openid_connect_provider.oidc-provider]
# }
# resource "aws_iam_role_policy_attachment" "eks-addon-moga-acc-role-policy-attachment" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks-moga-acc-role.name
#   depends_on = [aws_iam_role.eks-moga-acc-role]
# }
# resource "aws_iam_role_policy_attachment" "eks-moga-acc-role-policy-attachment" {
#   policy_arn = aws_iam_policy.moga-eks-moga-acc-role-policy.arn
#   role       = aws_iam_role.eks-moga-acc-role.name
# }
# resource "aws_iam_policy" "moga-eks-moga-acc-role-policy" {
#   name        = upper("aws-iam-policy-${var.stage}-${var.servicename}-eks-moga-acc-role")
#   description = "eks-moga-acc-role-policy"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": [
#               "rekognition:DetectModerationLabels",
#               "cognito-idp:AdminInitiateAuth",
#               "cognito-idp:AdminCreateUser",
#               "cognito-idp:AdminSetUserPassword",
#               "cognito-idp:AdminDeleteUser",
#               "cognito-idp:AdminUserGlobalSignOut",
#               "cognito-idp:AdminGetUser",
#               "cognito-idp:AdminUpdateUserAttributes",
#               "cognito-idp:AdminDisableUser",
#               "cognito-idp:AdminEnableUser",
#               "ses:SendEmail",
#               "sqs:*",
#               "s3:*",
#               "dynamodb:*",
#               "sns:CreatePlatformApplication",
#               "sns:CreatePlatformEndpoint",
#               "sns:DeletePlatformApplication",
#               "sns:GetEndpointAttributes",
#               "sns:GetPlatformApplicationAttributes",
#               "sns:ListEndpointsByPlatformApplication",
#               "sns:ListPlatformApplications",
#               "sns:SetEndpointAttributes",
#               "sns:SetPlatformApplicationAttributes",
#               "sns:DeleteEndpoint",
#               "sns:CreateTopic", "sns:ListTopics", "sns:SetTopicAttributes", "sns:DeleteTopic",
#               "sns:Publish",
#               "sns:GetTopicAttributes",
#               "sns:ListTagsForResource",
#               "sns:GetSubscriptionAttributes",
#               "sns:Subscribe",
#               "sns:Publish"
#             ],
#             "Resource": "*",
#             "Effect": "Allow",
#             "Sid": "default"
#         },
#         {
#             "Sid": "AllowExtKMSAccess",
#             "Effect": "Allow",
#             "Action": [
#               "kms:CreateGrant",
#               "kms:Decrypt",
#               "kms:GenerateDataKeyWithoutPlaintext",
#               "kms:ReEncryptFrom",
#               "kms:ReEncryptTo",
#               "kms:Encrypt",
#               "kms:GenerateDataKey",
#               "kms:GenerateDataKeyPair",
#               "kms:GenerateDataKeyPairWithoutPlaintext"
#             ],
#             "Resource": [
#               "${var.s3_kms_key_id}",
#               "${var.rds_data_kms_arn}",
#               "${var.sqs_kms_arn}"
#             ]
#         }
#     ]
# }
# EOF
# }
# data "aws_iam_policy_document" "moga-eks-assume-role-policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.oidc-provider.url, "https://", "")}:sub"
#       values   = [
#                   "system:serviceaccount:module-test:mock-admin",
#                   "system:serviceaccount:moga-be:moga-${var.stage}"
#                  ]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.oidc-provider.arn]
#       type        = "Federated"
#     }
#   }
# }

#####admin
resource "aws_iam_role" "eks-admin-acc-role" {
  assume_role_policy = data.aws_iam_policy_document.admin-eks-assume-role-policy.json
  name               = upper("aws-iam-eks-admin-acc-role")
  max_session_duration = 43200
  depends_on =[aws_iam_openid_connect_provider.oidc-provider]
}
resource "aws_iam_role_policy_attachment" "eks-addon-admin-acc-role-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-admin-acc-role.name
  depends_on = [aws_iam_role.eks-admin-acc-role]
}
resource "aws_iam_role_policy_attachment" "eks-admin-acc-role-policy-attachment" {
  policy_arn = aws_iam_policy.admin-eks-moga-acc-role-policy.arn
  role       = aws_iam_role.eks-admin-acc-role.name
}
resource "aws_iam_policy" "admin-eks-moga-acc-role-policy" {
  name        = upper("aws-iam-policy-${var.stage}-${var.servicename}-eks-admin-acc-role")
  description = "eks-admin-acc-role-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
              "cognito-idp:AdminInitiateAuth",
              "cognito-idp:AdminCreateUser",
              "cognito-idp:AdminSetUserPassword",
              "cognito-idp:AdminDeleteUser",
              "cognito-idp:AdminUserGlobalSignOut",
              "cognito-idp:AdminGetUser",
              "cognito-idp:AdminUpdateUserAttributes",
              "cognito-idp:AdminDisableUser",
              "cognito-idp:AdminEnableUser",
              "ses:SendEmail",
              "sqs:*",
              "s3:*",
              "dynamodb:*",
              "sns:CreatePlatformApplication",
              "sns:CreatePlatformEndpoint",
              "sns:DeletePlatformApplication",
              "sns:GetEndpointAttributes",
              "sns:GetPlatformApplicationAttributes",
              "sns:ListEndpointsByPlatformApplication",
              "sns:ListPlatformApplications",
              "sns:SetEndpointAttributes",
              "sns:SetPlatformApplicationAttributes",
              "sns:DeleteEndpoint",
              "sns:CreateTopic", "sns:ListTopics", "sns:SetTopicAttributes", "sns:DeleteTopic",
              "sns:Publish",
              "sns:GetTopicAttributes",
              "sns:ListTagsForResource",
              "sns:GetSubscriptionAttributes",
              "sns:Subscribe",
              "sns:Publish"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "default"
        },
        {
            "Sid": "AllowExtKMSAccess",
            "Effect": "Allow",
            "Action": [
              "kms:CreateGrant",
              "kms:Decrypt",
              "kms:GenerateDataKeyWithoutPlaintext",
              "kms:ReEncryptFrom",
              "kms:ReEncryptTo",
              "kms:Encrypt",
              "kms:GenerateDataKey",
              "kms:GenerateDataKeyPair",
              "kms:GenerateDataKeyPairWithoutPlaintext"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
data "aws_iam_policy_document" "admin-eks-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc-provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:module-test:mock",
                  "system:serviceaccount:admin-be:moga-admin-${var.stage}"
                 ]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc-provider.arn]
      type        = "Federated"
    }
  }
}

#####data
resource "aws_iam_role" "eks-data-acc-role" {
  assume_role_policy = data.aws_iam_policy_document.data-eks-assume-role-policy.json
  name               = upper("aws-iam-eks-data-acc-role")
  max_session_duration = 43200
  depends_on =[aws_iam_openid_connect_provider.oidc-provider]
}
resource "aws_iam_role_policy_attachment" "eks-addon-data-acc-role-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-data-acc-role.name
  depends_on = [aws_iam_role.eks-data-acc-role]
}
resource "aws_iam_role_policy_attachment" "eks-data-acc-role-policy-attachment" {
  policy_arn = aws_iam_policy.data-eks-moga-acc-role-policy.arn
  role       = aws_iam_role.eks-data-acc-role.name
}
resource "aws_iam_policy" "data-eks-moga-acc-role-policy" {
  name        = upper("aws-iam-policy-${var.stage}-${var.servicename}-eks-data-acc-role")
  description = "eks-data-acc-role-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
              "cognito-idp:AdminInitiateAuth",
              "cognito-idp:AdminCreateUser",
              "cognito-idp:AdminSetUserPassword",
              "cognito-idp:AdminDeleteUser",
              "cognito-idp:AdminUserGlobalSignOut",
              "cognito-idp:AdminGetUser",
              "cognito-idp:AdminUpdateUserAttributes",
              "cognito-idp:AdminDisableUser",
              "cognito-idp:AdminEnableUser",
              "ses:SendEmail",
              "sqs:*",
              "s3:*",
              "dynamodb:*",
              "sns:CreatePlatformApplication",
              "sns:CreatePlatformEndpoint",
              "sns:DeletePlatformApplication",
              "sns:GetEndpointAttributes",
              "sns:GetPlatformApplicationAttributes",
              "sns:ListEndpointsByPlatformApplication",
              "sns:ListPlatformApplications",
              "sns:SetEndpointAttributes",
              "sns:SetPlatformApplicationAttributes",
              "sns:DeleteEndpoint",
              "sns:CreateTopic", "sns:ListTopics", "sns:SetTopicAttributes", "sns:DeleteTopic",
              "sns:Publish",
              "sns:GetTopicAttributes",
              "sns:ListTagsForResource",
              "sns:GetSubscriptionAttributes",
              "sns:Subscribe",
              "sns:Publish"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "default"
        },
        {
            "Sid": "AllowExtKMSAccess",
            "Effect": "Allow",
            "Action": [
              "kms:CreateGrant",
              "kms:Decrypt",
              "kms:GenerateDataKeyWithoutPlaintext",
              "kms:ReEncryptFrom",
              "kms:ReEncryptTo",
              "kms:Encrypt",
              "kms:GenerateDataKey",
              "kms:GenerateDataKeyPair",
              "kms:GenerateDataKeyPairWithoutPlaintext"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
data "aws_iam_policy_document" "data-eks-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc-provider.url, "https://", "")}:sub"
      values   = [ "system:serviceaccount:data-be:data-${var.stage}" ]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc-provider.arn]
      type        = "Federated"
    }
  }
}

#####kaniko
# module "mock-server-ecr" {
#   source = "../ecr-mock-server"
#   ecr_name = "aws-ecr-${var.stage}-${var.servicename}-mock-server"
# }
# module "mock-admin-server-ecr" {
#   source = "../ecr-mock-server"
#   ecr_name = "aws-ecr-${var.stage}-${var.servicename}-admin-mock-server"
# }
# resource "aws_iam_role" "eks-kaniko-acc-role" {
#   assume_role_policy = data.aws_iam_policy_document.kaniko-eks-assume-role-policy.json
#   name               = upper("aws-iam-eks-kaniko-acc-role")
#   max_session_duration = 43200
#   depends_on =[aws_iam_openid_connect_provider.oidc-provider]
# }
# resource "aws_iam_role_policy_attachment" "eks-addon-kaniko-acc-role-policy-attachment" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks-kaniko-acc-role.name
#   depends_on = [aws_iam_role.eks-kaniko-acc-role]
# }
# resource "aws_iam_role_policy_attachment" "eks-kaniko-policy-attachment" {
#   policy_arn = aws_iam_policy.eks-kaniko-policy.arn
#   role       = aws_iam_role.eks-kaniko-acc-role.name
#   depends_on = [aws_iam_role.eks-kaniko-acc-role]
# }
# ## Kaniko policy
# resource "aws_iam_policy" "eks-kaniko-policy" {
#   name        = upper("aws-iam-policy-kaniko")
#   description = "eks-kaniko-policy"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "AccessMockServerImage",
#             "Effect": "Allow",
#             "Action": [
#                 "ecr:BatchCheckLayerAvailability",
#                 "ecr:BatchGetImage",
#                 "ecr:CompleteLayerUpload",
#                 "ecr:GetDownloadUrlForLayer",
#                 "ecr:InitiateLayerUpload",
#                 "ecr:PutImage",
#                 "ecr:UploadLayerPart"
#             ],
#             "Resource": [
#               "${module.mock-server-ecr.repository_arn}",
#               "${module.mock-admin-server-ecr.repository_arn}",
#               "${var.smoke_test_repository_arn}"
#             ]
#         },
#         {
#             "Sid": "AccessECR",
#             "Effect": "Allow",
#             "Action": "ecr:GetAuthorizationToken",
#             "Resource": "*"
#         },
#         {
#             "Sid": "AccessKanikoContextBucket",
#             "Effect": "Allow",
#             "Action": "s3:*",
#             "Resource": [
#               "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-kaniko-bucket",
#               "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-kaniko-bucket/*"
#             ]
#         },
#         {
#             "Sid": "AllowExtKMSAccess",
#             "Effect": "Allow",
#             "Action": [
#                 "kms:Encrypt",
#                 "kms:Decrypt",
#                 "kms:ReEncrypt*",
#                 "kms:GenerateDataKey*",
#                 "kms:DescribeKey"
#             ],
#             "Resource": "${var.s3_kms_key_id}"
#         }
#     ]
# }
# EOF
# }
# data "aws_iam_policy_document" "kaniko-eks-assume-role-policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.oidc-provider.url, "https://", "")}:sub"
#       values   = [ "system:serviceaccount:kaniko:kaniko" ]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.oidc-provider.arn]
#       type        = "Federated"
#     }
#   }
# }

#####batch
# resource "aws_iam_role" "eks-batch-acc-role" {
#   assume_role_policy = data.aws_iam_policy_document.batch-eks-assume-role-policy.json
#   name               = upper("aws-iam-eks-batch-acc-role")
#   max_session_duration = 43200
#   depends_on =[aws_iam_openid_connect_provider.oidc-provider]
# }
# resource "aws_iam_role_policy_attachment" "eks-addon-batch-acc-role-policy-attachment" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks-batch-acc-role.name
#   depends_on = [aws_iam_role.eks-batch-acc-role]
# }
# resource "aws_iam_role_policy_attachment" "eks-batch-acc-role-policy-attachment" {
#   policy_arn = aws_iam_policy.batch-eks-moga-acc-role-policy.arn
#   role       = aws_iam_role.eks-batch-acc-role.name
# }
# resource "aws_iam_policy" "batch-eks-moga-acc-role-policy" {
#   name        = upper("aws-iam-policy-${var.stage}-${var.servicename}-eks-batch-acc-role")
#   description = "eks-batch-acc-role-policy"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": [
#               "cognito-idp:AdminInitiateAuth",
#               "cognito-idp:AdminCreateUser",
#               "cognito-idp:AdminSetUserPassword",
#               "cognito-idp:AdminDeleteUser",
#               "cognito-idp:AdminUserGlobalSignOut",
#               "cognito-idp:AdminGetUser",
#               "cognito-idp:AdminUpdateUserAttributes",
#               "cognito-idp:AdminDisableUser",
#               "cognito-idp:AdminEnableUser",
#               "ses:SendEmail",
#               "sqs:*",
#               "s3:*",
#               "dynamodb:*",
#               "sns:CreatePlatformApplication",
#               "sns:CreatePlatformEndpoint",
#               "sns:DeletePlatformApplication",
#               "sns:GetEndpointAttributes",
#               "sns:GetPlatformApplicationAttributes",
#               "sns:ListEndpointsByPlatformApplication",
#               "sns:ListPlatformApplications",
#               "sns:SetEndpointAttributes",
#               "sns:SetPlatformApplicationAttributes",
#               "sns:DeleteEndpoint",
#               "sns:CreateTopic", "sns:ListTopics", "sns:SetTopicAttributes", "sns:DeleteTopic",
#               "sns:Publish",
#               "sns:GetTopicAttributes",
#               "sns:ListTagsForResource",
#               "sns:GetSubscriptionAttributes",
#               "sns:Subscribe",
#               "sns:Publish"
#             ],
#             "Resource": "*",
#             "Effect": "Allow",
#             "Sid": "default"
#         },
#         {
#             "Sid": "AllowExtKMSAccess",
#             "Effect": "Allow",
#             "Action": [
#               "kms:CreateGrant",
#               "kms:Decrypt",
#               "kms:GenerateDataKeyWithoutPlaintext",
#               "kms:ReEncryptFrom",
#               "kms:ReEncryptTo",
#               "kms:Encrypt",
#               "kms:GenerateDataKey",
#               "kms:GenerateDataKeyPair",
#               "kms:GenerateDataKeyPairWithoutPlaintext"
#             ],
#             "Resource": [
#               "${var.s3_kms_key_id}",
#               "${var.rds_data_kms_arn}",
#               "${var.sqs_kms_arn}"
#             ]
#         }
#     ]
# }
# EOF
# }
# data "aws_iam_policy_document" "batch-eks-assume-role-policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.oidc-provider.url, "https://", "")}:sub"
#       values   = [ "system:serviceaccount:batch-be:batch-${var.stage}" ]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.oidc-provider.arn]
#       type        = "Federated"
#     }
#   }
# }

# #####crm
# resource "aws_iam_role" "eks-crm-acc-role" {
#   assume_role_policy = data.aws_iam_policy_document.crm-eks-assume-role-policy.json
#   name               = upper("aws-iam-eks-crm-acc-role")
#   max_session_duration = 43200
#   depends_on =[aws_iam_openid_connect_provider.oidc-provider]
# }
# resource "aws_iam_role_policy_attachment" "eks-addon-crm-acc-role-policy-attachment" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks-crm-acc-role.name
#   depends_on = [aws_iam_role.eks-crm-acc-role]
# }
# resource "aws_iam_role_policy_attachment" "eks-crm-acc-role-policy-attachment" {
#   policy_arn = aws_iam_policy.crm-eks-moga-acc-role-policy.arn
#   role       = aws_iam_role.eks-crm-acc-role.name
# }
# resource "aws_iam_policy" "crm-eks-moga-acc-role-policy" {
#   name        = upper("aws-iam-policy-${var.stage}-${var.servicename}-eks-crm-acc-role")
#   description = "eks-crm-acc-role-policy"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": [
#               "ses:SendEmail"
#             ],
#             "Resource": "*",
#             "Effect": "Allow",
#             "Sid": "default"
#         },
#         {
#             "Sid": "AllowExtKMSAccess",
#             "Effect": "Allow",
#             "Action": [
#               "kms:CreateGrant",
#               "kms:Decrypt",
#               "kms:GenerateDataKeyWithoutPlaintext",
#               "kms:ReEncryptFrom",
#               "kms:ReEncryptTo",
#               "kms:Encrypt",
#               "kms:GenerateDataKey",
#               "kms:GenerateDataKeyPair",
#               "kms:GenerateDataKeyPairWithoutPlaintext"
#             ],
#             "Resource": [
#               "${var.s3_kms_key_id}",
#               "${var.rds_data_kms_arn}",
#               "${var.sqs_kms_arn}"
#             ]
#         }
#     ]
# }
# EOF
# }
# data "aws_iam_policy_document" "crm-eks-assume-role-policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.oidc-provider.url, "https://", "")}:sub"
#       values   = [ "system:serviceaccount:crm-be:crm-${var.stage}" ]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.oidc-provider.arn]
#       type        = "Federated"
#     }
#   }
# }

#####eks cluster-autoscaling
resource "aws_iam_role" "eks-cluster-autoscaling-role" {
  assume_role_policy = data.aws_iam_policy_document.as-eks-assume-role-policy.json
  name               = upper("aws-iam-eks-cluster-autoscaling-role")
  max_session_duration = 43200
  depends_on =[aws_iam_openid_connect_provider.oidc-provider]
}
data "aws_iam_policy_document" "as-eks-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc-provider.url, "https://", "")}:sub"
      values   = [
                  "system:serviceaccount:kube-system:aws-node",
                  "system:serviceaccount:kube-system:cluster-autoscaler"
                 ]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc-provider.arn]
      type        = "Federated"
    }
  }
}
resource "aws_iam_role_policy_attachment" "eks-addon-cluster-autoscaling-role-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-cluster-autoscaling-role.name
  depends_on = [aws_iam_role.eks-cluster-autoscaling-role]
}
resource "aws_iam_role_policy_attachment" "eks-cluster-autoscaling-role-policy-attachment" {
  policy_arn = aws_iam_policy.eks-cluster-autoscaling-policy.arn
  role       = aws_iam_role.eks-cluster-autoscaling-role.name
  depends_on = [aws_iam_role.eks-cluster-autoscaling-role]
}
## EKS Cluster Autoscaling policy
resource "aws_iam_policy" "eks-cluster-autoscaling-policy" {
  name        = upper("aws-iam-policy-${var.stage}-${var.servicename}-cluster-autoscaling")
  description = "eks-cluster-autoscaling-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}


### EKS Cluster Secretmanager Read policy
#resource "aws_iam_policy" "eks-cluster-secretsmanager-read-policy" {
#  name        = upper("aws-iam-policy-${var.stage}-${var.servicename}-fargate-secret")
#  description = "eks-cluster-secretsmanager-read-policy"
#
#  policy = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": {
#        "Effect": "Allow",
#        "Action": "secretsmanager:GetSecretValue",
#        "Resource": ["arn:aws:secretsmanager:${var.region}:${var.security_account}:secret:${var.cargo_secret_name}",
#                     "arn:aws:secretsmanager:${var.region}:${var.security_account}:secret:${var.kld_secret_name}"]
#    }
#}
#EOF
#}


            # "Resource": [
            #   "${var.s3_kms_key_id}",
            #   "${var.rds_data_kms_arn}",
            #   "${var.sqs_kms_arn}"
            # ]
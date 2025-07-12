# eks cluster role
resource "aws_iam_role" "eks-cluster-role" {
  name               = upper("aws-iam-${var.stage}-${var.servicename}-eks-cluster-role")
  assume_role_policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
}
EOF
}

# eks cluster managed Policy
resource "aws_iam_role_policy_attachment" "eks-cluster-role-attachment-clusterpolicy" {
  role       = aws_iam_role.eks-cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# eks cluster managed Policy
resource "aws_iam_role_policy_attachment" "eks-cluster-role-attachment-vpccontroller" {
  role       = aws_iam_role.eks-cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# eks cluster managed Policy
resource "aws_iam_role_policy_attachment" "eks-cluster-role-AmazonS3FullAccess" {
  role       = aws_iam_role.eks-cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# eks cluster managed Policy
resource "aws_iam_role_policy_attachment" "eks-cluster-role-KMSFullAccess" {
  role       = aws_iam_role.eks-cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}


# eks cluster custom policy
## add custom policy in data "aws_iam_policy_document" "eks-cluster-policy-data"
data "aws_iam_policy_document" "eks-cluster-policy-data" {
  statement {
    actions = ["s3:*"]
    resources = [ "*" ]
    effect = "Deny"
    condition {
      test     = "StringNotEquals"
      variable = "aws:ReaourceTag/servicename"
      values = [
        upper("${var.servicename}")
      ]
    }
  }

}
resource "aws_iam_policy" "eks-cluster-policy" {
  name        = upper("aws-iam-policy-${var.stage}-${var.servicename}-eks-cluster")
  path        = "/"
  description = "aws-iam-custom-policy-${var.stage}-${var.servicename}-eks-cluster"

  policy = data.aws_iam_policy_document.eks-cluster-policy-data.json
}
resource "aws_iam_role_policy_attachment" "eks-cluster-role-policy-attachment" {
  role       = aws_iam_role.eks-cluster-role.name
  policy_arn = aws_iam_policy.eks-cluster-policy.arn
}


# EKS node role
resource "aws_iam_role" "eks-node-role" {
  name               = upper("aws-iam-${var.stage}-${var.servicename}-eks-node-role")
  assume_role_policy = data.aws_iam_policy_document.eks-node-policy-data.json
}

data "aws_iam_policy_document" "eks-node-policy-data" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_policy" "FluentBitEKS" {
  name        = upper("aws-iam-policy-${var.stage}-${var.servicename}-fluentbiteks")
  description = "aws-iam-policy-${var.stage}-${var.servicename}-fluentbiteks"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "eks-node-role-attachment-fluentbit-policy" {
  role       = aws_iam_role.eks-node-role.name
  policy_arn = aws_iam_policy.FluentBitEKS.arn
}

## EKS Node Role managed policy
resource "aws_iam_role_policy_attachment" "eks-node-CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-policy-attachment" {
  policy_arn = aws_iam_policy.eks-node-policy.arn
  role       = aws_iam_role.eks-node-role.name
  depends_on = [aws_iam_role.eks-cluster-autoscaling-role]
}
## EKS Cluster Autoscaling policy
# "sts:AssumeRole" is temporary(should be deleted after prd is ready)
resource "aws_iam_policy" "eks-node-policy" {
  name        = upper("aws-iam-policy-${var.stage}-${var.servicename}-eks-node")
  description = "eks-node-policy"

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
            "Effect": "Allow"
        },
        {   "Sid" : "TMPSTGCognito",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}



#resource "aws_iam_role_policy_attachment" "eks-fargate-role-ec2containerregistrypoweruser-attachment" {
#  role       = aws_iam_role.eks-fargate-role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
#}
#resource "aws_iam_role_policy_attachment" "eks-fargate-role-ec2containerserviceforec2-attachment" {
#  role       = aws_iam_role.eks-fargate-role.name
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
#}
#resource "aws_iam_role_policy_attachment" "eks-fargate-role-ec2containerservice-attachment" {
#  role       = aws_iam_role.eks-fargate-role.name
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
#}










# data "aws_iam_policy_document" "alb_ingress_controller_assume_role" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.oidc-provider.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
#     }

#     principals {
#       type        = "Federated"
#       identifiers = [aws_iam_openid_connect_provider.oidc-provider.arn]
#     }
#   }
# }




# resource "aws_iam_role" "alb_ingress_controller_role" {
#   name               = "alb-ingress-controller-role"
#   assume_role_policy = data.aws_iam_policy_document.alb_ingress_controller_assume_role.json
#   # OIDC Provider + ServiceAccount(aws-load-balancer-controller) 매핑
# }

# resource "aws_iam_policy" "alb_ingress_controller_policy" {
#   name        = "AWSLoadBalancerControllerCustomPolicy"
#   description = "Custom policy for AWS Load Balancer Controller with all required permissions"
#   policy      = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "acm:DescribeCertificate",
#         "acm:ListCertificates",
#         "acm:GetCertificate"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ec2:AuthorizeSecurityGroupIngress",
#         "ec2:CreateSecurityGroup",
#         "ec2:CreateTags",
#         "ec2:DeleteTags",
#         "ec2:DeleteSecurityGroup",
#         "ec2:DescribeAccountAttributes",
#         "ec2:DescribeAddresses",
#         "ec2:DescribeInstances",
#         "ec2:DescribeInstanceStatus",
#         "ec2:DescribeSecurityGroups",
#         "ec2:DescribeSubnets",
#         "ec2:DescribeVpcs",
#         "ec2:ModifyInstanceAttribute",
#         "ec2:ModifyNetworkInterfaceAttribute",
#         "ec2:RevokeSecurityGroupIngress"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "elasticloadbalancing:AddListenerCertificates",
#         "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
#         "elasticloadbalancing:CreateListener",
#         "elasticloadbalancing:CreateLoadBalancer",
#         "elasticloadbalancing:CreateRule",
#         "elasticloadbalancing:CreateTargetGroup",
#         "elasticloadbalancing:DeleteListener",
#         "elasticloadbalancing:DeleteLoadBalancer",
#         "elasticloadbalancing:DeleteRule",
#         "elasticloadbalancing:DeleteTargetGroup",
#         "elasticloadbalancing:DeregisterTargets",
#         "elasticloadbalancing:DescribeListeners",
#         "elasticloadbalancing:DescribeLoadBalancers",
#         "elasticloadbalancing:DescribeRules",
#         "elasticloadbalancing:DescribeSSLPolicies",
#         "elasticloadbalancing:DescribeTags",
#         "elasticloadbalancing:DescribeTargetGroups",
#         "elasticloadbalancing:DescribeTargetHealth",
#         "elasticloadbalancing:ModifyListener",
#         "elasticloadbalancing:ModifyLoadBalancerAttributes",
#         "elasticloadbalancing:ModifyRule",
#         "elasticloadbalancing:ModifyTargetGroup",
#         "elasticloadbalancing:ModifyTargetGroupAttributes",
#         "elasticloadbalancing:RegisterTargets",
#         "elasticloadbalancing:SetIpAddressType",
#         "elasticloadbalancing:SetSecurityGroups",
#         "elasticloadbalancing:SetSubnets",
#         "elasticloadbalancing:TagResource",
#         "elasticloadbalancing:UntagResource"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "iam:ListServerCertificates",
#         "iam:GetServerCertificate"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "waf-regional:GetWebACLForResource",
#         "waf-regional:GetWebACL",
#         "waf-regional:AssociateWebACL",
#         "waf-regional:DisassociateWebACL",
#         "wafv2:GetWebACLForResource",
#         "wafv2:GetWebACL",
#         "wafv2:AssociateWebACL",
#         "wafv2:DisassociateWebACL"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "tag:GetResources",
#         "tag:TagResources"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:DescribeLogGroups",
#         "logs:DescribeLogStreams",
#         "logs:PutLogEvents",
#         "logs:GetLogEvents"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }




# resource "aws_iam_role_policy_attachment" "alb_ingress_controller_attach" {
#   role       = aws_iam_role.alb_ingress_controller_role.name
#   policy_arn = aws_iam_policy.alb_ingress_controller_policy.arn
# }

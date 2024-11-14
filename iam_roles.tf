
/* =============== Elastic Beanstalk EC2 Role ===============*/


# Create IAM Role for Elastic Beanstalk EC2 instances
resource "aws_iam_role" "eb_instance_role" {
  name = "aws-elasticbeanstalk-karmah-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the required policies for ECR, CloudWatch Logs, and S3 access
resource "aws_iam_policy" "eb_instance_policy" {
  name        = "eb-instance-policy"
  description = "Policy for Elastic Beanstalk EC2 instance to access ECR, CloudWatch Logs, and S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "logs:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::given-karma-project-bucket/*"
      }
    ]
  })
}

# Attach the policy to the instance role
resource "aws_iam_role_policy_attachment" "eb_instance_role_policy_attachment" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = aws_iam_policy.eb_instance_policy.arn
}

# Attach the Elastic Beanstalk Managed Policy to the Role
resource "aws_iam_role_policy_attachment" "eb_instance_web_tier_policy" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "eb_instance_worker_tier_policy" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "eb_instance_MulticontainerDocker_policy" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = aws_iam_role.eb_instance_role.name
  role = aws_iam_role.eb_instance_role.name
}

/* =============== Elastic Beanstalk Service Role ===============*/

# Create Service Role for Elastic Beanstalk
resource "aws_iam_role" "eb_service_role" {
  name = "aws-elasticbeanstalk-karmah-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM Role for Elastic Beanstalk EC2 instances
# resource "aws_iam_role" "eb_instance_role" {
#   name = "aws-elasticbeanstalk-ec2-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# Attach the Elastic Beanstalk Managed Policy to the Role
# resource "aws_iam_role_policy_attachment" "eb_service_BasicHealth_policy" {
#   role       = aws_iam_role.eb_service_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkBasicHealth"
# }

resource "aws_iam_role_policy_attachment" "eb_service_ManagedUpdates_policy" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

resource "aws_iam_instance_profile" "eb_service_profile" {
  name = aws_iam_role.eb_service_role.name
  role = aws_iam_role.eb_service_role.name
}


/* =============== CodeBuild Roles ===============*/

# Assume the default service role created by CodeBuild
resource "aws_iam_role" "codebuild_default_role" {
  name               = "CodeBuildBasePolicy-${var.app_name}-us-west-2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# CodeBuild base policy
resource "aws_iam_policy" "codebuild_base_policy" {
  name        = "CodeBuildBasePolicy-${var.app_name}"
  description = "Policy for ${var.app_name} CodeBuild"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"

    },
     {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::bitcube-codepipeline-bucket", 
                "arn:aws:s3:::bitcube-codepipeline-bucket/*" 
            ]
        },
                {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-us-east-1-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codebuild:StopBuild",
        "codebuild:ListBuildsForProject"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the base policy to the default CodeBuild role
resource "aws_iam_role_policy_attachment" "codebuild_base_policy_attachment" {
  role       = aws_iam_role.codebuild_default_role.name
  policy_arn = aws_iam_policy.codebuild_base_policy.arn
}


# Policy for CodeStar Connections in CodeBuild
resource "aws_iam_policy" "codebuild_connections_policy" {
  name        = "CodeBuildConnectionsPolicy-${var.app_name}"
  description = "Policy for CodeStar Connections in CodeBuild"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:GetConnectionToken",
        "codestar-connections:GetConnection",
        "codeconnections:GetConnectionToken",
        "codeconnections:GetConnection",
        "codeconnections:UseConnection"
      ],
      "Resource": [
        "arn:aws:codeconnections:us-west-2:135808943588:connection/e45787a2-fc5d-453f-a71f-58608f57d13b"
       
        
      ]
    }
  ]
}
EOF
}



# Attach the connections policy to the default CodeBuild role
resource "aws_iam_role_policy_attachment" "codebuild_connections_policy_attachment" {
  role       = aws_iam_role.codebuild_default_role.name
  policy_arn = aws_iam_policy.codebuild_connections_policy.arn
}

# Policy for CloudWatch Logs in CodeBuild
resource "aws_iam_policy" "codebuild_cloudwatch_logs_policy" {
  name        = "CodeBuildCloudWatchLogsPolicy-${var.app_name}"
  description = "Policy for CloudWatch Logs in CodeBuild"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource":
      [
        "arn:aws:logs:us-west-2:135808943588:log-group:CodeBuildDockerDemo",
        "arn:aws:logs:us-west-2:135808943588:log-group:CodeBuildDockerDemo:*"
      ]
    }
  ]
}
EOF
}

# Attach the CloudWatch Logs policy to the default CodeBuild role
resource "aws_iam_role_policy_attachment" "codebuild_cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.codebuild_default_role.name
  policy_arn = aws_iam_policy.codebuild_cloudwatch_logs_policy.arn
}

# Attach the AWS Managed Policy to the default service role
resource "aws_iam_role_policy_attachment" "attach_ec2_instance_profile_policy" {
  role       = aws_iam_role.codebuild_default_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}


# Add S3 permissions for CodeBuild
resource "aws_iam_policy" "codebuild_s3_access_policy" {
  name        = "CodeBuildS3AccessPolicy-${var.app_name}"
  description = "Policy to allow CodeBuild to access S3 artifacts"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::given-karma-project-bucket",
        "arn:aws:s3:::given-karma-project-bucket/*"
      ]
    }
  ]
}
EOF
}

# Attach the S3 access policy to the default CodeBuild role
resource "aws_iam_role_policy_attachment" "codebuild_s3_access_policy_attachment" {
  role       = aws_iam_role.codebuild_default_role.name
  policy_arn = aws_iam_policy.codebuild_s3_access_policy.arn
}



/*================== CodePipeline============== */


resource "aws_iam_role" "codepipeline_role" {
  name = "CodepipelineServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


/* CodePipeline IAM Policies */
data "aws_iam_policy_document" "cicd-pipeline-policies" {
  # Existing statements...

  # Additional permissions based on your request
  statement {
    sid = "PassRolePermission"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid = "CodeDeployPermissions"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid = "CommonPermissions"
    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid = "LambdaPermissions"
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid = "CloudFormationPermissions"
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "cloudformation:CreateChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:SetStackPolicy",
      "cloudformation:ValidateTemplate"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid = "ECRPermissions"
    actions = [
      "ecr:DescribeImages"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid = "AppConfigPermissions"
    actions = [
      "appconfig:StartDeployment",
      "appconfig:StopDeployment",
      "appconfig:GetDeployment"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    sid = "CodePipelineConnectionPermissions"
    actions = [
      "codestar-connections:GetConnectionToken",
      "codestar-connections:GetConnection",
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection",
      "codeconnections:UseConnection",
      "codestar-connections:UseConnection"
    ]
    resources = ["arn:aws:codeconnections:eu-west-2:135808943588:connection/c0167713-4df8-47e7-b05d-ae4a79b22aaa*"]
    effect    = "Allow"

  }
  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:StopBuild",
      "codebuild:ListBuildsForProject"
    ]

    resources = ["*"]
  }
}

/* Attach Policy to CodePipeline Role */
resource "aws_iam_policy" "cicd-pipeline-policy" {
  name        = "karmah-pipeline-policy"
  path        = "/"
  description = "Pipeline policy"
  policy      = data.aws_iam_policy_document.cicd-pipeline-policies.json
}

resource "aws_iam_role_policy_attachment" "cicd-pipeline-attachment" {
  policy_arn = aws_iam_policy.cicd-pipeline-policy.arn
  role       = aws_iam_role.codepipeline_role.id
}


resource "aws_iam_policy" "codepipeline_s3_access_policy" {
  name        = "KarmahCodePipelineS3AccessPolicy"
  description = "Policy to allow CodePipeline to access S3 artifacts"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject",
        ],
        Resource = [
          "arn:aws:s3:::given-karma-project-bucket",
          "arn:aws:s3:::given-karma-project-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_access_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_s3_access_policy.arn
}

resource "aws_s3_bucket_policy" "codepipeline_bucket_policy" {
  bucket = var.bucket

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::135808943588:role/${aws_iam_role.codepipeline_role.name}"
        },
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket}",
          "arn:aws:s3:::${var.bucket}/*"
        ]
      }
    ]
  })
}


/* AWS Amplify Role */
resource "aws_iam_role" "amplify_role" {
  name = "AmplifyServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "amplify.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


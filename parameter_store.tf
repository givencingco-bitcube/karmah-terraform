# Store AWS Region in SSM Parameter Store
resource "aws_ssm_parameter" "aws_region" {
  name  = "/karma/aws-region"
  type  = "String"
  value = "us-west-2"
}

# Store ECR Repository Name in SSM Parameter Store
resource "aws_ssm_parameter" "ecr_repository" {
  name  = "/karma/ecr-repository"
  type  = "String"
  value = var.image_repo_name
}

# Store Docker Image Tag in SSM Parameter Store
resource "aws_ssm_parameter" "image_tag" {
  name  = "/karma/image-tag"
  type  = "String"
  value = "latest"
}

# Store Container Name in SSM Parameter Store
resource "aws_ssm_parameter" "container_name" {
  name  = "/karma/container-name"
  type  = "String"
  value = "python-container"
}
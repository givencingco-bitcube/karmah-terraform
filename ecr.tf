# Create the ECR repository with mutable image tags
resource "aws_ecr_repository" "bitcube_repository" {
  name                 = var.image_repo_name
  image_tag_mutability = "MUTABLE"

  # Use the same repository policy as above if needed
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
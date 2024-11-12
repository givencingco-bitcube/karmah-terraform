
resource "aws_codepipeline" "codepipeline" {
  name     = "karma-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = var.codestart_connector_cred
        FullRepositoryId     = "givencingco-bitcube/karmah-web-main-copy"
        BranchName           = "main"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.karmah_codebuild.name
      }
    }
  }

  #   stage {
  #     name = "Deploy"

  #     action {
  #       name            = "Deploy"
  #       category        = "Deploy"
  #       owner           = "AWS"
  #       provider        = "CodeDeploy"
  #       input_artifacts = ["build_output"]
  #       version         = "1"

  #       configuration = {
  #         ApplicationName    = aws_codedeploy_app.Bitcube_nextjs.name  
  #         DeploymentGroupName = aws_codedeploy_deployment_group.bitcube_deployment_group1.deployment_group_name  
  #       }
  #     }
  #   }
}

resource "aws_codestarconnections_connection" "github_connection" {
  name          = "github_connection"
  provider_type = "GitHub"
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket" {
  bucket = var.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
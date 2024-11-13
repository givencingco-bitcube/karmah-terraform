resource "aws_amplify_app" "karmah_amplify" {
  name       = "Karmah-web-main"
  repository = var.github_url

  access_token = local.github_token
  enable_branch_auto_build = true

  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        preBuild:
          commands:
            - yarn install
        build:
          commands:
            - yarn run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  environment_variables = {
    ENV = "test"
  }
}

resource "aws_amplify_branch" "amplify_branch" {
  app_id            = aws_amplify_app.karmah_amplify.id
  branch_name       = var.branch_name
  enable_auto_build = true
}

output "amplify_app_id" {
  value = aws_amplify_app.karmah_amplify.id
}
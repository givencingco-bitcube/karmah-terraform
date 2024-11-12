variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "135808943588"
}

variable "codestart_connector_cred" {
  type        = string
  default     = "arn:aws:codeconnections:eu-west-2:135808943588:connection/c0167713-4df8-47e7-b05d-ae4a79b22aaa"
  description = "Variable for CodeStar connection credentials"

}

variable "image_repo_name" {
  description = "Image repo name"
  type        = string
  default     = "karmah"
}

variable "image_tag" {
  description = "Image tag"
  type        = string
  default     = "latest"
}


variable "region" {
  description = "Region"
  type        = string
  default     = "eu-west-2"
}

# variable "bucket" {
#   description = "Bucket "
#   type        = string
#   default     = "given-cingco-devops-directive-tf-state"
# }

variable "github_url" {
  description = "source of the buildpec file on GitHub "
  type        = string
  default     = "https://github.com/givencingco-bitcube/karmah-web-main-copy"
}


# variable "db_user" {
#   description = "username for database"
#   type        = string
# }

# variable "db_pass" {
#   description = "password for database"
#   type        = string
#   sensitive   = true
# }

variable "app_name" {
  default = "KarmahCodeBuild"
}
variable "ami" {
  description = "Profile"
  type        = string
}

variable "bucket" {
  description = "Bucket "
  type        = string
}
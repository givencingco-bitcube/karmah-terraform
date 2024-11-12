# Define Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "Karmah-web"
  description = "Karmah web Elastic Beanstalk"
}

# Create Elastic Beanstalk application version
resource "aws_elastic_beanstalk_application_version" "eb_app_ver" {
  bucket      = aws_s3_bucket.terraform_state.id
  key         = aws_s3_object.object.key
  application = aws_elastic_beanstalk_application.eb_app.name
  name        = "v1"
}

# Define Launch Template
resource "aws_launch_template" "karmah_launch_template" {
  name_prefix   = "karmah-template"
  image_id      = var.ami
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }

  key_name = module.key_pair.key_pair_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [module.EC2-security-group.security_group_id]
  }

}

# Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "tfenv" {
  name                = "dev-karmah-env"
  application         = aws_elastic_beanstalk_application.eb_app.name             # Elastic Beanstalk application name
  solution_stack_name = "64bit Amazon Linux 2023 v6.3.0 running Node.js 20"       # Define current version of the platform
  description         = "environment for karmah web app"                          # Define environment description
  version_label       = aws_elastic_beanstalk_application_version.eb_app_ver.name # Define version label

  # Attach to VPC
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = module.vpc.vpc_id # VPC ID reference
  }

  # Launch Template Integration
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "LaunchTemplateId"
    value     = aws_launch_template.karmah_launch_template.id
  }

  # Elastic Beanstalk EC2 Instance role
  setting {
    namespace = "aws:autoscaling:launchconfiguration"  # Define namespace
    name      = "IamInstanceProfile"                   # Define name
    value     = "aws-elasticbeanstalk-karmah-ec2-role" # Define value
  }

  # Specify the key pair to attach to EC2 instances
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = module.key_pair.key_pair_name
  }

  # Define public subnets for Load Balancer (if using an ELB)
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", module.vpc.public_subnets)
  }

  # Optionally configure other settings like security groups
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = module.EC2-security-group.security_group_id
  }

  # Enable public IP assignment
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }
}

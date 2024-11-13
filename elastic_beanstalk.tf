# # # Define Elastic Beanstalk application
# # resource "aws_elastic_beanstalk_application" "eb_app" {
# #   name        = "Karmah-web"
# #   description = "Karmah web Elastic Beanstalk"
# # }

# # # Create Elastic Beanstalk application version
# # resource "aws_elastic_beanstalk_application_version" "eb_app_ver" {
# #   bucket      = aws_s3_bucket.terraform_state.id
# #   key         = aws_s3_object.object.key 
# #   application = aws_elastic_beanstalk_application.eb_app.name
# #   name        = "v1"
# # }



# # # Define Launch Template
# # resource "aws_launch_template" "karmah_launch_template" {
# #   name_prefix   = "karmah-template"
# #   image_id      = var.ami
# #   instance_type = "t2.micro"

# #   lifecycle {
# #     create_before_destroy = true
# #   }

# #   key_name = module.key_pair.key_pair_name

# #   network_interfaces {
# #     associate_public_ip_address = true
# #     security_groups             = [module.EC2-security-group.security_group_id]
# #   }

# # }

# # # Elastic Beanstalk Environment
# # resource "aws_elastic_beanstalk_environment" "beanstalk_env" {
# #   name                = "dev-karmah-env"
# #   application         = aws_elastic_beanstalk_application.eb_app.name            
# #   solution_stack_name = "64bit Amazon Linux 2023 v6.3.0 running Node.js 20"       
# #   description         = "environment for karmah web app"                          
# #   version_label       = aws_elastic_beanstalk_application_version.eb_app_ver.name 

# #   # Attach to VPC
# #   setting {
# #     namespace = "aws:ec2:vpc"
# #     name      = "VPCId"
# #     value     = module.vpc.vpc_id 
# #   }


# #   # Elastic Beanstalk EC2 Instance role
# #   setting {
# #     namespace = "aws:autoscaling:launchconfiguration"  
# #     name      = "IamInstanceProfile"                   
# #     value     = "aws-elasticbeanstalk-karmah-ec2-role"
# #   }

# #   # Specify the key pair to attach to EC2 instances
# #   setting {
# #     namespace = "aws:autoscaling:launchconfiguration"
# #     name      = "EC2KeyName"
# #     value     = module.key_pair.key_pair_name
# #   }

# #   # Define public subnets for Load Balancer (if using an ELB)
# #   setting {
# #     namespace = "aws:ec2:vpc"
# #     name      = "Subnets"
# #     value     = join(",", module.vpc.public_subnets)
# #   }

# #   # Optionally configure other settings like security groups
# #   setting {
# #     namespace = "aws:autoscaling:launchconfiguration"
# #     name      = "SecurityGroups"
# #     value     = module.EC2-security-group.security_group_id
# #   }

# #   # Enable public IP assignment
# #   setting {
# #     namespace = "aws:ec2:vpc"
# #     name      = "AssociatePublicIpAddress"
# #     value     = "true"
# #   }
# # }

# # Define Elastic Beanstalk application
# resource "aws_elastic_beanstalk_application" "eb_app" {
#   name        = "Karmah-web"
#   description = "Karmah web Elastic Beanstalk"
# }

# # Create Elastic Beanstalk application version
# resource "aws_elastic_beanstalk_application_version" "eb_app_ver" {
#   bucket      = aws_s3_bucket.terraform_state.id
#   key         = aws_s3_object.object.key 
#   application = aws_elastic_beanstalk_application.eb_app.name
#   name        = "v1"
# }

# # Define Elastic Beanstalk Environment for Docker
# resource "aws_elastic_beanstalk_environment" "beanstalk_env" {
#   name                = "dev-karmah-env"
#   application         = aws_elastic_beanstalk_application.eb_app.name            
#   solution_stack_name = "64bit Amazon Linux 2023 v4.4.0 running Docker"  # Docker solution stack
#   description         = "Environment for Karmah web app"                          
#   version_label       = aws_elastic_beanstalk_application_version.eb_app_ver.name 

#   # Elastic Beanstalk Docker Configuration to use ECR image
#   setting {
#     namespace = "aws:elasticbeanstalk:container:docker"
#     name      = "Image"
#     value     = "${aws_ecr_repository.bitcube_repository.repository_url}:latest"  # ECR image URL and tag
#   }

#   # Attach to VPC
#   setting {
#     namespace = "aws:ec2:vpc"
#     name      = "VPCId"
#     value     = module.vpc.vpc_id 
#   }

#   # Elastic Beanstalk EC2 Instance role with ECR access permissions
#   setting {
#     namespace = "aws:autoscaling:launchconfiguration"
#     name      = "IamInstanceProfile"
#     value     = "aws-elasticbeanstalk-karmah-ec2-role"  # Ensure this role has ECR access permissions
#   }

#   # Specify the key pair to attach to EC2 instances
#   setting {
#     namespace = "aws:autoscaling:launchconfiguration"
#     name      = "EC2KeyName"
#     value     = module.key_pair.key_pair_name
#   }

#   # Define public subnets for Load Balancer (if using an ELB)
#   setting {
#     namespace = "aws:ec2:vpc"
#     name      = "Subnets"
#     value     = join(",", module.vpc.public_subnets)
#   }

#   # Optionally configure other settings like security groups
#   setting {
#     namespace = "aws:autoscaling:launchconfiguration"
#     name      = "SecurityGroups"
#     value     = module.EC2-security-group.security_group_id
#   }

#   # Enable public IP assignment
#   setting {
#     namespace = "aws:ec2:vpc"
#     name      = "AssociatePublicIpAddress"
#     value     = "true"
#   }
# }

/* ==========Security Group for EC2 Instances (ALB--> EC2)============*/
module "EC2-security-group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "karmah-security-group"
  description = "Security group for web-server with HTTP and SSH ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  /*===Inbound Rules===*/
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"


      description = "Allow traffic only from the ALB security group"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTP outbound traffic"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTP outbound traffic"
    }

  ]

  /*===Outbound Rules===*/
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  ]

  tags = {
    Name = "karma-SG"
  }
}
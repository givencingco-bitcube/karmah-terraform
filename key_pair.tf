
# provider "tls" {

# }

# resource "tls_private_key" "this" {
#   algorithm = "RSA"
# }

# resource "aws_secretsmanager_secret" "ec2_key_pair" {
#   name        = module.key_pair.key_pair_name
#   description = "EC2 Key Pair for SSH access"
# }

# resource "aws_secretsmanager_secret_version" "ec2_key_pair" {
#   secret_id = aws_secretsmanager_secret.ec2_key_pair.id
#   secret_string = jsonencode({
#     private_key = tls_private_key.this.private_key_pem
#     public_key  = tls_private_key.this.public_key_openssh
#   })
# }


# module "key_pair" {
#   source = "terraform-aws-modules/key-pair/aws"

#   key_name   = "Karmah_Key_Pair10"
#   public_key = trimspace(tls_private_key.this.public_key_openssh)

# }
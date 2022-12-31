resource "aws_cloud9_environment_ec2" "cloud9-dev" {
  instance_type = var.instance_type
  name          = var.name
}
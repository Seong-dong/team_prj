resource "aws_cloud9_environment_membership" "cloud9-env" {
  environment_id = var.cloud9_id
  permissions    = var.permissions
  user_arn       = var.user_arn
}
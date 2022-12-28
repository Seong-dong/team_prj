resource "aws_eks_cluster" "demo" {
  name     = var.cluster-name
  role_arn = aws_iam_role.demo-cluster.arn

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    security_group_ids = [aws_security_group.demo-cluster.id]
    subnet_ids = [
      aws_subnet.VPC_HQ_public_1a.id,
      aws_subnet.VPC_HQ_public_1c.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

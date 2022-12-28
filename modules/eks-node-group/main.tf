resource "aws_eks_node_group" "eks-ng" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.iam_role_arn
  subnet_ids      = var.subnet_list

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
}
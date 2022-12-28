resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.name}-eks-cluster"
  role_arn = var.iam_role_arn

  #enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    security_group_ids = var.sg_list
    subnet_ids = var.subnet_list

    #노드그룹 통신을 위한 설정
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

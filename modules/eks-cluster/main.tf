resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.name}"
  role_arn = var.iam_role_arn

  #enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    security_group_ids = var.sg_list
    subnet_ids         = var.subnet_list

    #노드그룹 통신을 위한 설정
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

# //신뢰할수있는 사용자 등록
# resource "aws_eks_identity_provider_config" "eks-cluster-oidc-provider" {
#   cluster_name = aws_eks_cluster.eks-cluster.name

#   oidc {
#     client_id                     = var.client_id
#     identity_provider_config_name = "eks-example"
#     issuer_url                    = "${aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer}"
#   }

#   depends_on = [
#     aws_eks_cluster.eks-cluster
#   ]
# }

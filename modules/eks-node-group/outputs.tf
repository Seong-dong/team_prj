output "ng_sg" {
    description = "Identifier of the remote access EC2 Security Group."
    value = "${aws_eks_node_group.eks-ng.resources[0].remote_access_security_group_id}"
  
}
//main-outputs
output "aws_id" {
  description = "The AWS Account ID."
  value       = data.aws_caller_identity.this.account_id
}
output "ng_sg" {
  description = "Identifier of the remote access EC2 Security Group."
  value = module.eks_node_group.ng_sg
  
}
# output "cluster_oidc" {
#   description = "eks_cluster_identity"
#   value       = module.eks_cluster.cluster_oidc
# }
# output "subnet" {
#   description = "The name of vpc hq id"
#   value       = module.subnet_public.subnet
# }

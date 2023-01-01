//main-outputs
output "aws_id" {
  description = "The AWS Account ID."
  value       = data.aws_caller_identity.this.account_id
}

# output "subnet" {
#   description = "The name of vpc hq id"
#   value       = module.subnet_public.subnet
# }

//modules-subnet-outputs
output "subnet" {
  description = "The name of vpc hq id"
  value       = module.subnet_public.subnet
}

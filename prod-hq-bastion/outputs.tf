output "public_ip_associate" {
    value = module.ec2_bastion.public_ip_associate
  
}
output "sg_id" {
    value = module.ec2_bastion.sg_id
  
}
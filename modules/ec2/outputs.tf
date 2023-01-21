output "ec2_id" {
    value = aws_instance.ec2.id
  
}

output "public_ip_associate" {
    value = aws_instance.ec2.associate_public_ip_address
  
}

output "sg_id" {
    value = aws_network_interface.eni.security_groups
}
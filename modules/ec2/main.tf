resource "aws_network_interface" "eni" {
  subnet_id = var.public_ip_associate ? var.public_subnet : var.private_subnet
  # private_ips = ["172.16.10.100"]
  security_groups = var.sg_list
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "ubuntu" {
  ami = var.ami_name
  # "ami-0ab04b3ccbadfae1f"
  instance_type = var.instance_type
  # "t2.micro"

  tags = {
    Name = "${var.tag_name}"
  }

  network_interface {
    network_interface_id = aws_network_interface.eni.id
    device_index         = 0
    # delete_on_termination = true
    
    # security_groups = var.sg_list
    
  }
  
  key_name = var.key_name
}

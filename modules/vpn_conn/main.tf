resource "aws_vpn_connection" "example" {
  customer_gateway_id = var.cgw_id
  
  transit_gateway_id = var.tgw_id
  
  type = "ipsec.1"

  tunnel1_preshared_key = var.preshared_key
  tunnel2_preshared_key = var.preshared_key

  static_routes_only = true
  tags = {
    Name = "terraform_ipsec_vpn_example"
  }
}
#   outside_ip_address_type                 = "PrivateIpv4"
#   transport_transit_gateway_attachment_id = data.aws_ec2_transit_gateway_dx_gateway_attachment.example.id
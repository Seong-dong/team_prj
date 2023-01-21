resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = var.cgw_ip
  type       = "ipsec.1"

  tags = {
    Name = "cgw"
  }
}
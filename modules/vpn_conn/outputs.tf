output "vpn_conn_tunnel-1_ip" {
  value = aws_vpn_connection.example.tunnel1_address
}
output "vpn_conn_tunnel-2_ip" {
  value = aws_vpn_connection.example.tunnel2_address
}
output "attach_id" {
  value = aws_vpn_connection.example.transit_gateway_attachment_id
  
}
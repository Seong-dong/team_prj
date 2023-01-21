resource "aws_ec2_transit_gateway_route" "example" {
  destination_cidr_block         = var.cidr
  transit_gateway_attachment_id  = var.attatch_id
  transit_gateway_route_table_id = var.route_table_id
}
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-vpc-attatch" {
  subnet_ids         = var.subnet_id_list
  transit_gateway_id = var.tgw_id
  vpc_id             = var.vpc_id
}

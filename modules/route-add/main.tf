resource "aws_route" "r" {
  route_table_id            = "rtb-4fbb3ac4"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = var.igw_id
  depends_on                = [var.route_public_id]
#   depends_on                = [aws_route_table.testing]
}
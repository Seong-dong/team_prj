resource "aws_route" "route-igw-add" {
  count = format("%.1s", var.gw_type) == "i" ? 1 : 0
  route_table_id            = var.route_id
  destination_cidr_block    = var.destination_cidr
  gateway_id = var.igw_id
  depends_on                = [var.route_id]
#   depends_on                = [aws_route_table.testing]
}
resource "aws_route" "route-nat-add" {
  count = format("%.1s", var.gw_type) == "n" ? 1 : 0
  route_table_id            = var.route_id
  destination_cidr_block    = var.destination_cidr
  nat_gateway_id = var.nat_id
  depends_on                = [var.route_id]
#   depends_on                = [aws_route_table.testing]
}

# transit_gateway_id -
resource "aws_route" "route-tgw-add" {
  count = format("%.1s", var.gw_type) == "t" ? 1 : 0
  route_table_id            = var.route_id
  destination_cidr_block    = var.destination_cidr
  # "10.0.0.0/8"
  transit_gateway_id = var.tgw_id
  depends_on                = [var.route_id]
}
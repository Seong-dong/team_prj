resource "aws_route" "route-igw-add" {
  count = format("%.1s", var.gw_type) == "i" ? 1 : 0
  route_table_id            = var.route_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = var.igw_id
  depends_on                = [var.route_id]
#   depends_on                = [aws_route_table.testing]
}
resource "aws_route" "route-nat-add" {
  count = format("%.1s", var.gw_type) == "i" ? 0 : 1
  route_table_id            = var.route_id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = var.nat_id
  depends_on                = [var.route_id]
#   depends_on                = [aws_route_table.testing]
}
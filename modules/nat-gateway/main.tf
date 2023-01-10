resource "aws_eip" "nat-eip" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = var.subnet_id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  # depends_on = [aws_internet_gateway.example]
}
# resource "aws_nat_gateway" "example" {
#   connectivity_type = "private"
#   subnet_id         = aws_subnet.example.id
# }

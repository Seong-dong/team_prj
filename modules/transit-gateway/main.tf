resource "aws_ec2_transit_gateway" "tgw" {
  description = "tgw"
  tags = {
    Name = "${var.tag_name}"
  }
}
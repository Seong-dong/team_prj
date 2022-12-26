resource "aws_vpc" "vpcHq" {
    # cidr_block       = "10.3.0.0/16"
    cidr_block       = var.cidr_block
    // instance_tenancy = "default"

    tags = {
    Name = "test"
    }
}
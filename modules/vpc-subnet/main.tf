resource "aws_subnet" "subnets" {
    vpc_id     = var.vpc_id
    # module.vpc_hq.vpc_hq_id
    
    for_each = var.subnet-az-list
    availability_zone = each.value.name
    cidr_block = each.value.cidr

    map_public_ip_on_launch = true
    
    tags = {
    Name = "${var.vpc_id}-${each.value.name}"
    # Name = module.vpc_hq.vpcHq.id
    }
}
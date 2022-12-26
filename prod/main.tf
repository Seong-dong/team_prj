provider "aws" {
    region = "ap-northeast-2"

    #2.x버전의 AWS공급자 허용
    version = "~> 2.0"
  
}

module "vpc_hq" {
    source = "../modules/vpc"

    cidr_block = var.cidr_block
    
}
# resource "aws_vpc" "vpcHq" {
#     cidr_block       = "10.3.0.0/16"
#     // instance_tenancy = "default"

#     tags = {
#     Name = "test"
#     }
# }
module "subnet_list" {
  
}
resource "aws_subnet" "subnets" {
    vpc_id     = module.vpc_hq.vpc_hq_id
    
    for_each = var.subnet-az-list
    availability_zone = each.value.name
    cidr_block = each.value.cidr

    map_public_ip_on_launch = true
    
    # tags = {
    # # Name = "${each.value.name}"
    # Name = module.vpc_hq.vpcHq.id
    # }
}
// prod - main

provider "aws" {
    region = "ap-northeast-2"

    #2.x버전의 AWS공급자 허용
    version = "~> 2.0"
  
}

# module "vpc_hq" {
module "vpc_hq" {
    source = "../modules/vpc"
    tag_name = var.prod_name
    cidr_block = "10.3.0.0/16"
    
}

module "vpc_igw" {
    source = "../modules/igw"
    tag_name = var.prod_name
    vpc_id = module.vpc_hq.vpc_hq_id
}

module "subnet_list" {
    source = "../modules/vpc-subnet"

    vpc_id = module.vpc_hq.vpc_hq_id
    subnet-az-list = var.subnet-az-list
}

// public route
module "route_public" {
    source = "../modules/route-table"
    tag_name = var.prod_name
    vpc_id = module.vpc_hq.vpc_hq_id
    
}

module "route_add" {
    source = "../modules/route-add"
    route_public_id = module.route_public.route_public_id
    igw_id = module.vpc_igw.igw_id
}

module "route_association" {
    source = "../modules/route-association"
    route_table_id = module.route_public.route_public_id
    subnet_ids = [module.subnet_list.subnet.zone-a.id, module.subnet_list.subnet.zone-c.id]

  
}
# EKS테스트 할때 활성
# module "ecr" {
#     source = "../modules/ecr"

#     names_list = ["web", "nginx", "mariadb"]
# }


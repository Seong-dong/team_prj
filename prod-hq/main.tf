// prod - main
terraform {
  backend "remote"{
    hostname = "app.terraform.io"
    organization = "22shop"

    workspaces {
      name = "tf-cloud-backend"
    }
  }

}
provider "aws" {
  region = "ap-northeast-2"

  #2.x버전의 AWS공급자 허용
  version = "~> 2.0"

}

locals {
  common_tags = {
    project = "22shop"
    owner = "icurfer"

  }
}
# module "vpc_hq" {
module "vpc_hq" {
  source     = "../modules/vpc"
#   source = "github.com/Seong-dong/team_prj/tree/main/modules/vpc"
  tag_name   = "${local.common_tags.project}-vpc"
  cidr_block = "10.3.0.0/16"

}

module "vpc_igw" {
  source   = "../modules/igw"
  
  vpc_id   = module.vpc_hq.vpc_hq_id

  tag_name = "${local.common_tags.project}-vpc_igw"
}

module "subnet_public" {
  source = "../modules/vpc-subnet"

  vpc_id         = module.vpc_hq.vpc_hq_id
  subnet-az-list = var.subnet-az-list
  public_ip_on = true
  vpc_name = "${local.common_tags.project}-public"
}

// public route
module "route_public" {
  source   = "../modules/route-table"
  tag_name = "${local.common_tags.project}-route_table"
  vpc_id   = module.vpc_hq.vpc_hq_id

}

module "route_add" {
  source          = "../modules/route-add"
  route_public_id = module.route_public.route_public_id
  igw_id          = module.vpc_igw.igw_id
}

module "route_association" {
  source         = "../modules/route-association"
  route_table_id = module.route_public.route_public_id
  
  association_count = 2
  subnet_ids     = [module.subnet_public.subnet.zone-a.id, module.subnet_public.subnet.zone-c.id]
}

# EKS테스트 할때 활성
# module "ecr" {
#     source = "../modules/ecr"

#     names_list = ["web", "nginx", "mariadb"]
# }


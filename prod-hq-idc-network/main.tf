// prod - main
provider "aws" {
  region                  = "ap-northeast-2"
  profile                 = "22shop"
  shared_credentials_file = "C:/Users/aa/.aws/credentials"
  #3.x버전의 AWS공급자 허용
  version = "~> 3.0"

}

locals {
  region = "ap-northeast-2"
  common_tags = {
    project = "22shop-hq-idc"
    owner   = "icurfer"
  }
  cidr = {
    vpc    = "10.3.0.0/16"
    zone_a = "10.3.1.0/24"
    zone_c = "10.3.3.0/24"
    zone_b = "10.3.2.0/24"
    zone_d = "10.3.4.0/24"
  }
  tcp_port = {
    any_port    = 0
    http_port   = 80
    https_port  = 443
    ssh_port    = 22
    dns_port    = 53
    django_port = 8000
    mysql_port  = 3306
    nfs_port    = 2049
  }
  udp_port = {
    dns_port = 53
  }
  any_protocol  = "-1"
  tcp_protocol  = "tcp"
  icmp_protocol = "icmp"
  all_ips       = ["0.0.0.0/0"]
}

// GET 계정정보
data "aws_caller_identity" "this" {}

# module "vpc_hq" {
module "vpc_hq" {
  source = "../modules/vpc"
  #   source = "github.com/Seong-dong/team_prj/tree/main/modules/vpc"
  tag_name   = "${local.common_tags.project}-hq-vpc"
  cidr_block = local.cidr.vpc

}

module "vpc_igw" {
  source = "../modules/igw"

  vpc_id = module.vpc_hq.vpc_hq_id

  tag_name = "${local.common_tags.project}-hq-igw"

  depends_on = [
    module.vpc_hq
  ]
}

module "subnet_public" {
  source = "../modules/vpc-subnet"

  vpc_id = module.vpc_hq.vpc_hq_id
  # subnet-az-list = var.subnet-az-public
  subnet-az-list = {
    "zone-a" = {
      name = "${local.region}a"
      cidr = local.cidr.zone_a
    }
    "zone-c" = {
      name = "${local.region}c"
      cidr = local.cidr.zone_c
    }
  }
  public_ip_on = true
  # vpc_name       = "${local.common_tags.project}-public"
  #alb-ingress 생성을 위해 지정
  vpc_name = "${local.common_tags.project}-public"
}

// public route
module "route_public" {
  source   = "../modules/route-table"
  tag_name = "${local.common_tags.project}-hq-rt-tbl"
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
  subnet_ids        = [module.subnet_public.subnet.zone-a.id, module.subnet_public.subnet.zone-c.id]
}


module "subnet_private" {
  source = "../modules/vpc-subnet"

  vpc_id = module.vpc_hq.vpc_hq_id
  # subnet-az-list = var.subnet-az-public
  subnet-az-list = {
    "zone-b" = {
      name = "${local.region}b"
      cidr = local.cidr.zone_b
    }
    "zone-d" = {
      name = "${local.region}d"
      cidr = local.cidr.zone_d
    }
  }
  public_ip_on = false
  # vpc_name       = "${local.common_tags.project}-public"
  #alb-ingress 생성을 위해 지정
  vpc_name = "${local.common_tags.project}-hq-private"
}
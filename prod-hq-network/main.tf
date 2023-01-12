// prod - main
provider "aws" {
  region                  = "ap-northeast-2"
  profile                 = "22shop"
  shared_credentials_file = "C:/Users/aa/.aws/credentials"
  #2.x버전의 AWS공급자 허용
  version = "~> 3.0"

}

locals {
  region = "ap-northeast-2"
  common_tags = {
    project = "22shop-eks"
    owner   = "icurfer"
  }
  cidr = {
    vpc            = "10.3.0.0/16"
    zone_a         = "10.3.1.0/24"
    zone_c         = "10.3.3.0/24"
    zone_a_private = "10.3.2.0/24"
    zone_c_private = "10.3.4.0/24"
    zone_a_tgw     = "10.3.5.0/24"
    zone_c_tgw     = "10.3.6.0/24"
  }
  tcp_port = {
    any_port    = 0
    http_port   = 80
    https_port  = 443
    ssh_port    = 22
    dns_port    = 53
    django_port = 8000
    mysql_port  = 3306
  }
  udp_port = {
    dns_port = 53
  }
  any_protocol  = "-1"
  tcp_protocol  = "tcp"
  icmp_protocol = "icmp"
  all_ips       = ["0.0.0.0/0"]

  node_group_scaling_config = {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  eks_ingress_type = {
    public  = "kubernetes.io/role/elb"
    private = "kubernetes.io/role/internal-elb=1"
  }
}

// GET 계정정보
data "aws_caller_identity" "this" {}

// 테라폼클라우드
# data "terraform_remote_state" "hq_vpc_id" {
#   backend = "remote"

#   config = {
#     organization = "22shop"

#     workspaces = {
#       name = "hq-network"
#     }
#   }
# }

// eks를 위한 iam역할 생성 데이터 조회
data "aws_iam_policy_document" "eks-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "eks_node_group_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

//vpc 생성
module "vpc_hq" {
  source = "../modules/vpc"
  #   source = "github.com/Seong-dong/team_prj/tree/main/modules/vpc"
  tag_name   = "${local.common_tags.project}-vpc"
  cidr_block = "10.3.0.0/16"

}

//외부통신 gateway
module "vpc_igw" {
  source = "../modules/igw"

  vpc_id = module.vpc_hq.vpc_hq_id

  tag_name = "${local.common_tags.project}-vpc_igw"

  depends_on = [
    module.vpc_hq
  ]
}

// public 서브넷 생성
module "subnet_public" {
  source = "../modules/vpc-subnet"

  vpc_id = module.vpc_hq.vpc_hq_id
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
  k8s_ingress = true
  # vpc_name = local.eks_ingress_type.public
  vpc_name = local.eks_ingress_type.private
}
// private외부통신을 위한 nat
module "nat_gw" {
  source    = "../modules/nat-gateway"
  subnet_id = module.subnet_public.subnet.zone-a.id

  depends_on = [
    module.vpc_igw
  ]
}

// public route
module "route_public" {
  source   = "../modules/route-table"
  tag_name = "${local.common_tags.project}-public_tbl-sdjo"
  vpc_id   = module.vpc_hq.vpc_hq_id

}

module "route_add" {
  source   = "../modules/route-add"
  route_id = module.route_public.route_id
  igw_id   = module.vpc_igw.igw_id
  gw_type  = "igw"
  destination_cidr = "0.0.0.0/0"
}

module "route_association" {
  source         = "../modules/route-association"
  route_table_id = module.route_public.route_id

  association_count = 2
  subnet_ids        = [module.subnet_public.subnet.zone-a.id, module.subnet_public.subnet.zone-c.id]
}
#----------------------------------------------------------------------------------------------------#
######################################################################################################
#----------------------------------------------------------------------------------------------------#
module "subnet_private" {
  source = "../modules/vpc-subnet"

  vpc_id = module.vpc_hq.vpc_hq_id
  subnet-az-list = {
    "zone-a" = {
      name = "${local.region}a"
      cidr = local.cidr.zone_a_private
    }
    "zone-c" = {
      name = "${local.region}c"
      cidr = local.cidr.zone_c_private
    }
  }
  public_ip_on = false
  # vpc_name       = "${local.common_tags.project}-public"
  #alb-ingress 생성을 위해 지정
  k8s_ingress = false
  vpc_name    = "null"
}

// private route
module "route_private" {
  source   = "../modules/route-table"
  tag_name = "${local.common_tags.project}-private_tbl-sdjo"
  vpc_id   = module.vpc_hq.vpc_hq_id

}
module "route_add_nat" {
  source   = "../modules/route-add"
  route_id = module.route_private.route_id
  nat_id   = module.nat_gw.nat_id
  gw_type  = "nat"
  destination_cidr = "0.0.0.0/0"
}
module "route_association_nat" {
  source         = "../modules/route-association"
  route_table_id = module.route_private.route_id

  association_count = 2
  subnet_ids        = [module.subnet_private.subnet.zone-a.id, module.subnet_private.subnet.zone-c.id]
}
#----------------------------------------------------------------------------------------------------#
######################################################################################################
#----------------------------------------------------------------------------------------------------#
//tgw-subnet
module "subnet_private_tgw" {
  source = "../modules/vpc-subnet"

  vpc_id = module.vpc_hq.vpc_hq_id
  subnet-az-list = {
    "zone-a" = {
      name = "${local.region}a"
      cidr = local.cidr.zone_a_tgw
    }
    "zone-c" = {
      name = "${local.region}c"
      cidr = local.cidr.zone_c_tgw
    }
  }
  public_ip_on = false
  # vpc_name       = "${local.common_tags.project}-public"
  #alb-ingress 생성을 위해 지정
  k8s_ingress = false
  vpc_name    = "null"
}
// private route
module "route_private_tgw" {
  source   = "../modules/route-table"
  tag_name = "${local.common_tags.project}-private_tbl_tgw-sdjo"
  vpc_id   = module.vpc_hq.vpc_hq_id

}
module "route_association_tgw" {
  source         = "../modules/route-association"
  route_table_id = module.route_private_tgw.route_id

  association_count = 2
  subnet_ids        = [module.subnet_private_tgw.subnet.zone-a.id, module.subnet_private_tgw.subnet.zone-c.id]
}

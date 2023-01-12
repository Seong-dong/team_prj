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

// 테라폼클라우드
// web-network
data "terraform_remote_state" "hq_vpc_id" {
  backend = "remote"

  config = {
    organization = "22shop"

    workspaces = {
      name = "web-network-sdjo"
    }
  }
}
// hq-network
data "terraform_remote_state" "web_vpc_id" {
  backend = "remote"

  config = {
    organization = "22shop"

    workspaces = {
      name = "hq-network"
    }
  }
}
// hidc-network
data "terraform_remote_state" "hidc_vpc_id" {
  backend = "remote"

  config = {
    organization = "22shop"

    workspaces = {
      name = "hidc-network-bkkim"
    }
  }
}
locals {
  account_id = data.aws_caller_identity.this.account_id

  hq_vpc_id   = data.terraform_remote_state.hq_vpc_id.outputs.vpc_id
  web_vpc_id  = data.terraform_remote_state.web_vpc_id.outputs.vpc_id
  hidc_vpc_id = data.terraform_remote_state.hidc_vpc_id.outputs.vpc_id

  hq_subnet   = data.terraform_remote_state.hq_vpc_id.outputs.private_subnet_tgw
  web_subnet  = data.terraform_remote_state.web_vpc_id.outputs.private_subnet_tgw
  hidc_subnet = data.terraform_remote_state.hidc_vpc_id.outputs.private_subnet

}

// tg 생성
module "tgw" {
  source   = "../modules/transit-gateway"
  tag_name = "22shop-tgw"
}
// tg 연결
module "tgw-hq_vpc-attatch" {
  source         = "../modules/transit-gw-vpc-attatch"
  tgw_id         = module.tgw.tgw_id
  vpc_id         = local.hq_vpc_id
  subnet_id_list = [local.hq_subnet.zone-a.id, local.hq_subnet.zone-c.id]

  depends_on = [
    module.tgw
  ]
}
module "tgw-web_vpc-attatch" {
  source         = "../modules/transit-gw-vpc-attatch"
  tgw_id         = module.tgw.tgw_id
  vpc_id         = local.web_vpc_id
  subnet_id_list = [local.web_subnet.zone-a.id, local.web_subnet.zone-c.id]

  depends_on = [
    module.tgw
  ]
}
module "tgw-hidc_vpc-attatch" {
  source         = "../modules/transit-gw-vpc-attatch"
  tgw_id         = module.tgw.tgw_id
  vpc_id         = local.hidc_vpc_id
  subnet_id_list = [local.hidc_subnet.zone-a.id, local.hidc_subnet.zone-c.id]

  depends_on = [
    module.tgw
  ]
}
// route table에 경로 추가.
module "route_add_hq_public" {
  source           = "../modules/route-add"
  route_id         = data.terraform_remote_state.hq_vpc_id.outputs.route_public_id
  tgw_id           = module.tgw.tgw_id
  gw_type          = "tgw"
  destination_cidr = "10.0.0.0/8"

  depends_on = [
    module.tgw
  ]
}

module "route_add_hq_private" {
  source           = "../modules/route-add"
  route_id         = data.terraform_remote_state.hq_vpc_id.outputs.route_private_id
  tgw_id           = module.tgw.tgw_id
  gw_type          = "tgw"
  destination_cidr = "10.0.0.0/8"

  depends_on = [
    module.tgw
  ]
}

module "route_add_web_public" {
  source           = "../modules/route-add"
  route_id         = data.terraform_remote_state.web_vpc_id.outputs.route_public_id
  tgw_id           = module.tgw.tgw_id
  gw_type          = "tgw"
  destination_cidr = "10.0.0.0/8"

  depends_on = [
    module.tgw
  ]
}

module "route_add_web_private" {
  source           = "../modules/route-add"
  route_id         = data.terraform_remote_state.web_vpc_id.outputs.route_private_id
  tgw_id           = module.tgw.tgw_id
  gw_type          = "tgw"
  destination_cidr = "10.0.0.0/8"

  depends_on = [
    module.tgw
  ]
}

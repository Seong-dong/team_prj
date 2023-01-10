// prod-hq-efs - main
provider "aws" {
  region = "ap-northeast-2"

  #2.x버전의 AWS공급자 허용
  version = "~> 3.0"

}

locals {
  // 초기 설정값
  vpc_id        = data.terraform_remote_state.hq_vpc_id.outputs.vpc_id
  public_subnet = data.terraform_remote_state.hq_vpc_id.outputs.subnet
  common_tags = {
    project = "22shop-efs"
    owner   = "icurfer"

  }
  tcp_port = {
    http_port   = 80
    https_port  = 443
    ssh_port    = 22
    dns_port    = 53
    # django_port = 8000
    # mysql_port  = 3306
    nfs_port    = 2049
  }
#   udp_port = {
#     dns_port = 53
#   }

  any_port    = 0

  any_protocol  = "-1"
  tcp_protocol  = "tcp"
  icmp_protocol = "icmp"
  all_ips       = ["0.0.0.0/0"]

}

// GET 계정정보
data "aws_caller_identity" "this" {}

// 테라폼클라우드
data "terraform_remote_state" "hq_vpc_id" {
  backend = "remote"

  config = {
    organization = "icurfer" // 초기 설정값

    workspaces = {
      name = "tf-cloud-network"
    }
  }
}

// 보안그룹 생성
module "efs_sg" {
  source  = "../modules/sg"
  sg_name = "${local.common_tags.project}-sg"
  vpc_id = local.vpc_id

}

module "efs_sg_ingress_http" {
  for_each          = local.tcp_port
  source            = "../modules/sg-rule-add"
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
  security_group_id = module.efs_sg.sg_id

  tag_name = each.key
}

module "efs_sg_egress_all" {
  source            = "../modules/sg-rule-add"
  type              = "egress"
  from_port         = local.any_protocol
  to_port           = local.any_protocol
  protocol          = local.any_protocol
  cidr_blocks       = local.all_ips
  security_group_id = module.efs_sg.sg_id

  tag_name = "egress-all"
}

module "efs_fs" {
  source            = "../modules/efs-fs"
  
}

module "efs-mnt_tg" {
  source            = "../modules/efs-mnt-tg"
  fs_id = module.efs_fs.efs_fs_id
  subnet_id = "${local.public_subnet.zone-a.id}"
  sg_list = [module.efs_sg.sg_id]
  
  depends_on = [
    module.efs_fs
  ]
}

module "efs-mnt_t2" {
  source            = "../modules/efs-mnt-tg"
  fs_id = module.efs_fs.efs_fs_id
  subnet_id = "${local.public_subnet.zone-c.id}"
  sg_list = [module.efs_sg.sg_id]
  
  depends_on = [
    module.efs_fs
  ]
}
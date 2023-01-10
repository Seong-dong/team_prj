// prod - dev
provider "aws" {
  region                  = "ap-northeast-2"
  profile                 = "22shop"
  shared_credentials_file = "C:/Users/aa/.aws/credentials"
  #4.x버전의 AWS공급자 허용
  version = "~> 4.0"

}


// GET 계정정보
data "aws_caller_identity" "this" {}
// 테라폼클라우드
data "terraform_remote_state" "hq_vpc_id" {
  backend = "remote"

  config = {
    organization = "22shop"

    workspaces = {
      name = "hq-network"
    }
  }
}
locals {
  account_id = data.aws_caller_identity.this.account_id
  vpc_id        = data.terraform_remote_state.hq_vpc_id.outputs.vpc_id
  subnet = data.terraform_remote_state.hq_vpc_id.outputs.private_subnet
  common_tags = {
    project = "22shop"
    owner   = "icurfer"

  }
  tcp_port = {
    # any_port    = 0
    http_port   = 80
    https_port  = 443
    ssh_port    = 22
    # dns_port    = 53
    # django_port = 8000
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
}
module "ec2_bastion" {
  source = "../modules/ec2"
  ami_name = "ami-035233c9da2fabf52" //amazon linux
  instance_type = "t2.micro"
  tag_name = "bastion"
  public_ip_associate = true
  key_name = "default-shop"
  private_subnet = data.terraform_remote_state.hq_vpc_id.outputs.private_subnet.zone-a.id
  public_subnet = data.terraform_remote_state.hq_vpc_id.outputs.public_subnet.zone-a.id
  sg_list = [module.ec2_sg.sg_id]
}

module "ec2_sg" {
  source  = "../modules/sg"
  sg_name = "${local.common_tags.project}-bastion-sg"
  vpc_id = local.vpc_id

}
module "ec2_sg_ingress_http" {
  for_each          = local.tcp_port
  source            = "../modules/sg-rule-add"
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
  security_group_id = module.ec2_sg.sg_id

  tag_name = each.key
}

module "ec2_sg_egress_all" {
  source            = "../modules/sg-rule-add"
  type              = "egress"
  from_port         = local.any_protocol
  to_port           = local.any_protocol
  protocol          = local.any_protocol
  cidr_blocks       = local.all_ips
  security_group_id = module.ec2_sg.sg_id

  tag_name = "egress-all"
}
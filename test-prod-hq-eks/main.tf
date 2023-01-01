// prod - main
provider "aws" {
  region = "ap-northeast-2"

  #2.x버전의 AWS공급자 허용
  version = "~> 2.0"

}

locals {
  vpc_id = data.terraform_remote_state.hq_vpc_id.outputs.vpc_id
  public_subnet = data.terraform_remote_state.hq_vpc_id.outputs.subnet
  common_tags = {
    project = "22shop"
    owner   = "icurfer"

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
}

// GET 계정정보
data "aws_caller_identity" "this" {}

// 테라폼클라우드 네트워크 상태파일 조회
data "terraform_remote_state" "hq-network" {
  backend = "remote"

  config = {
    organization = "22shop"

    workspaces = {
      name = "tf-22shop-network"
    }
  }
}

// eks 클러스터 
// 보안그룹 생성
module "alb_sg" {
  source  = "../modules/sg"
  sg_name = "${local.common_tags.project}-sg"
  # vpc_id  = module.vpc_hq.vpc_hq_id
  vpc_id = local.vpc_id

}

module "alb_sg_ingress_http" {
  for_each          = local.tcp_port
  source            = "../modules/sg-rule-add"
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
  security_group_id = module.eks_sg.sg_id

  tag_name = each.key
}

module "alb_sg_egress_all" {
  source            = "../modules/sg-rule-add"
  type              = "egress"
  from_port         = local.any_protocol
  to_port           = local.any_protocol
  protocol          = local.any_protocol
  cidr_blocks       = local.all_ips
  security_group_id = module.eks_sg.sg_id

  tag_name = "egress-all"
}

# ALB
resource "aws_alb" "test" {
  name                             = "test-alb"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [ aws_security_group.alb.id ]
  subnets                          = [ aws_subnet.VPC_HQ_public_1a.id , aws_subnet.VPC_HQ_public_1c.id ]
  enable_cross_zone_load_balancing = true
}
resource "aws_alb_target_group" "test" {
  name     = "tset-alb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC_HQ.id
  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
    interval = 15
    timeout  = 3
    healthy_threshold =2
    unhealthy_threshold =2
  }
}
resource "aws_alb_target_group_attachment" "privateInstance01" {
  target_group_arn = aws_alb_target_group.test.arn
  target_id = aws_instance.testEC201.id
  port = 80
}
resource "aws_alb_target_group_attachment" "privateInstance02" {
  target_group_arn = aws_alb_target_group.test.arn
  target_id = aws_instance.testEC202.id
  port = 80
}
resource "aws_alb_listener" "test" {
  load_balancer_arn = aws_alb.test.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.test.arn
  }
}
// prod - dev
provider "aws" {
  region                  = "ap-northeast-2"
  profile                 = "22shop"
  shared_credentials_file = "C:/Users/aa/.aws/credentials"
  #4.x버전의 AWS공급자 허용
  version = "~> 4.0"

}


locals {
  common_tags = {
    project = "22shop"
    owner   = "icurfer"

  }
  tcp_port = {
    # any_port    = 0
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

locals {
  dns_name = "ddochi.ml"
}
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

module "rote53" {
  source = "../modules/route53"
  name   = local.dns_name
}

resource "aws_route53_record" "www" {
  zone_id = module.rote53.zone_id
  name    = "hq.ddochi.ml"
  type    = "A"

  alias {
    name                   = "k8s-22shopekscluster-42f56c4a0b-625381113.ap-northeast-2.elb.amazonaws.com"
    zone_id                = "ZWKZPGTI48KDX" //rt53이아니고 로드밸런서 호스팅영역
    evaluate_target_health = true
  }
}
// prod - dev
provider "aws" {
  region = "ap-northeast-2"

  #4.x버전의 AWS공급자 허용
  version = "~> 4.0"

}

locals {
  common_tags = {
    project = "22shop_dev"
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
}

// GET 계정정보
data "aws_caller_identity" "this" {}

// cloud9를 위한 iam역할 생성 데이터 조회
data "aws_iam_policy_document" "cloud9_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# EKS테스트 할때 활성
module "ecr" {
    source = "../modules/ecr"

    names_list = ["app"]
    //names_list = ["web", "nginx", "mariadb"]
}
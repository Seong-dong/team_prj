// prod - main
provider "aws" {
  region = "ap-northeast-2"

  #2.x버전의 AWS공급자 허용
  version = "~> 3.0"

}

locals {
  vpc_id        = data.terraform_remote_state.hq_vpc_id.outputs.vpc_id
  public_subnet = data.terraform_remote_state.hq_vpc_id.outputs.subnet
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

// 테라폼클라우드
data "terraform_remote_state" "hq_vpc_id" {
  backend = "remote"

  config = {
    organization = "icurfer"

    workspaces = {
      name = "tf-22shop-network"
    }
  }
}

// eks 클러스터 역할 생성
module "eks_cluster_iam" {
  source   = "../modules/iam"
  iam_name = "eks-cluster-test"
  policy   = data.aws_iam_policy_document.eks-assume-role-policy.json
  tag_name = local.common_tags.project
}

// eks 클러스터 역할 정책 추가
module "eks_cluster_iam_att" {
  source    = "../modules/iam-policy-attach"
  iam_name  = "eks-cluster-att"
  role_name = module.eks_cluster_iam.iam_name
  arn       = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  depends_on = [
    module.eks_cluster_iam
  ]
}
module "eks_cluster_iam_att2" {
  source    = "../modules/iam-policy-attach"
  iam_name  = "eks-cluster-att"
  role_name = module.eks_cluster_iam.iam_name
  arn       = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"

  depends_on = [
    module.eks_cluster_iam
  ]
}

// eks 노드그룹 역할 생성 및 추가
module "eks_nodegroup_iam" {
  source   = "../modules/iam"
  iam_name = "eks-nodegroup-test"
  policy   = data.aws_iam_policy_document.eks_node_group_role.json
  tag_name = local.common_tags.project
}
module "eks_nodegroup_iam_att_1" {
  source    = "../modules/iam-policy-attach"
  iam_name  = "eks-nodegroup-att"
  role_name = module.eks_nodegroup_iam.iam_name
  arn       = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

  depends_on = [
    module.eks_nodegroup_iam
  ]
}
module "eks_nodegroup_iam_att_2" {
  source    = "../modules/iam-policy-attach"
  iam_name  = "eks-nodegroup-att"
  role_name = module.eks_nodegroup_iam.iam_name
  arn       = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

  depends_on = [
    module.eks_nodegroup_iam
  ]
}
module "eks_nodegroup_iam_att_3" {
  source    = "../modules/iam-policy-attach"
  iam_name  = "eks-nodegroup-att"
  role_name = module.eks_nodegroup_iam.iam_name
  arn       = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

  depends_on = [
    module.eks_nodegroup_iam
  ]
}

// 보안그룹 생성
module "eks_sg" {
  source  = "../modules/sg"
  sg_name = "${local.common_tags.project}-sg"
  # vpc_id  = module.vpc_hq.vpc_hq_id
  vpc_id = local.vpc_id

}

module "eks_sg_ingress_http" {
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

module "eks_sg_egress_all" {
  source            = "../modules/sg-rule-add"
  type              = "egress"
  from_port         = local.any_protocol
  to_port           = local.any_protocol
  protocol          = local.any_protocol
  cidr_blocks       = local.all_ips
  security_group_id = module.eks_sg.sg_id

  tag_name = "egress-all"
}

module "eks_cluster" {
  source       = "../modules/eks-cluster"
  name         = local.common_tags.project
  iam_role_arn = module.eks_cluster_iam.iam_arn
  sg_list      = [module.eks_sg.sg_id]
  # subnet_list  = [module.subnet_public.subnet.zone-a.id, module.subnet_public.subnet.zone-c.id] #변경해야될수있음.
  subnet_list = [local.public_subnet.zone-a.id, local.public_subnet.zone-c.id]

  depends_on = [
    module.eks_cluster_iam,
    module.eks_sg,
  ]

  client_id = data.aws_caller_identity.this.id

}

module "eks_node_group" {
  source          = "../modules/eks-node-group"
  node_group_name = "${local.common_tags.project}-ng"
  cluster_name    = module.eks_cluster.cluster_name
  # iam_role_arn    = module.eks_nodegroup_iam.iam_arn
  iam_role_arn = "arn:aws:iam::448559955338:role/eks-nodegroup-test"
  # subnet_list  = [module.subnet_public.subnet.zone-a.id, module.subnet_public.subnet.zone-c.id] #변경해야될수있음.
  subnet_list = [local.public_subnet.zone-a.id, local.public_subnet.zone-c.id]

  desired_size = local.node_group_scaling_config.desired_size
  max_size     = local.node_group_scaling_config.max_size
  min_size     = local.node_group_scaling_config.min_size

  depends_on = [
    module.eks_nodegroup_iam,
    module.eks_cluster,
  ]
}

module "ng_sg_ingress_http" {
  # for_each          = local.tcp_port
  source            = "../modules/sg-rule-add"
  type              = "ingress"
  from_port         = "2049"
  to_port           = "2049"
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
  security_group_id = module.eks_node_group.ng_sg

  tag_name = "ng_sg_sub"

  depends_on = [
    module.eks_node_group
  ]
}

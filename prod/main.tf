// prod - main

provider "aws" {
    region = "ap-northeast-2"

    #2.x버전의 AWS공급자 허용
    version = "~> 2.0"
  
}

# module "vpc_hq" {
module "vpc_hq" {
    source = "../modules/vpc"

    cidr_block = "10.3.0.0/16"
    
}

module "vpc_igw" {
    source = "../modules/igw"

    vpc_id = module.vpc_hq.vpc_hq_id
}

module "subnet_list" {
    source = "../modules/vpc-subnet"

    vpc_id = module.vpc_hq.vpc_hq_id
    subnet-az-list = {
        "zone-a" = {
            name = "ap-northeast-2a"
            cidr = "10.3.1.0/24"
        }
        "zone-b" = {
            name = "ap-northeast-2b"
            cidr = "10.3.2.0/24"
        }
        "zone-c" = {
            name = "ap-northeast-2c"
            cidr = "10.3.3.0/24"
        }
        "zone-d" = {
            name = "ap-northeast-2d"
            cidr = "10.3.4.0/24"
        }
    }
}

module "ecr" {
    source = "../modules/ecr"

    names_list = ["web", "nginx", "mariadb"]
}


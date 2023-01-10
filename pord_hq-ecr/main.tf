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

module "ecr" {
  source = "../modules/ecr"

  names_list = ["app"]
  //names_list = ["web", "nginx", "mariadb"]
}

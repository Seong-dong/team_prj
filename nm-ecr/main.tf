//ecr make
provider "aws" {
    region = "ap-northeast-2"

    #2.x버전의 AWS공급자 허용
    version = "~> 2.0"
  
}

resource "aws_ecr_repository" "foo" {
  name                 = "demo-flask-backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "bar" {
  name                 = "demo-frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
# resource "null_resource" "null_for_ecr_get_login_password" {
#   provisioner "local-exec" {
#     command = <<EOF
#       aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ${aws_ecr_repository.foo.repository_url}
#     EOF
#   }
# }

 

# output "ecr_registry_id" {
#   value = aws_ecr_repository.foo.registry_id
# }

# output "ecr_repository_url" {
#   value = aws_ecr_repository.foo.repository_url
# }
# --region ${AWS_REGION}
resource "aws_route53_zone" "primary" {
  name = var.name

  //public 이면 vpc 불필요
  count = var.public ? 0 : 1
  vpc {
    vpc_id = var.vpc_id
  }
}

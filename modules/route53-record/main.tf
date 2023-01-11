resource "aws_route53_record" "default" {
  count   = var.type_alias ? 0 : 1
  zone_id = var.zone_id
  name    = var.prefix
  type    = var.type
  ttl     = var.ttl
  records = var.record_list
}

resource "aws_route53_record" "alias" {
  count   = var.type_alias ? 1 : 0
  zone_id = var.zone_id
  name    = var.name

  type    = var.type

  ttl     = var.ttl
  
  records = var.record_list
}

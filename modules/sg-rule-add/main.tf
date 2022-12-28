resource "aws_security_group_rule" "sg-rule-add" {
  description       = "Security groups rule add"

  type              = var.type
  from_port         = var.set_ports.http
  to_port           = var.set_ports.http
  protocol          = var.set_ports.protocol_tcp #tcp
  cidr_blocks       = var.cidr_blocks
  security_group_id = var.sg_id

}

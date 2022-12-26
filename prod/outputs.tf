//main - output

output "vpc_hq_id" {
  description = "The name of vpc hq id"
  value = aws_vpc.vpcHq.id
}
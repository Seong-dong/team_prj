variable "node_group_name" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "iam_role_arn" {
  type = string
}
variable "subnet_list" {
  type = list(string)
}
variable "desired_size" {
  type = number
}
variable "max_size" {
  type = number
}
variable "min_size" {
  type = number
}

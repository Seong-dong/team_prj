variable "name" {
  type = string
}
variable "iam_role_arn" {
  type = string
}
variable "sg_list" {
  type = list(string)

}
variable "subnet_list" {
  type = list(string)

}

variable "client_id" {
  type = string

}

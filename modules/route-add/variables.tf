variable "route_id" {
    description = "value"
    type = string
}

variable "gw_type" {
    description = "gateway type. nat or igw"
    type = string
}
variable "igw_id" {
    description = "value"
    type = string
    default = "null"
}
variable "nat_id" {
    description = "value"
    type = string
    default = "null"
}
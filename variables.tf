variable "region" {
  default = ""
}

variable "namespace" {
  default = ""
}

variable "stage" {
  default = ""
}

variable "name" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "availability_zones" {
  type = "list"
}

variable "igw_id" {
  default = ""
}

variable "vpc_default_route_table_id" {
  default = ""
}

variable "nat_gateway_eip_enabled" {
  default = true
}

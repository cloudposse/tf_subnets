variable "subnet_type_tag_key" {
  type        = string
  default     = "cpco.io/subnet/type"
  description = "Key for subnet type tag to provide information about the type of subnets, e.g. `cpco.io/subnet/type=private` or `cpco.io/subnet/type=public`"
}

variable "subnet_type_tag_value_format" {
  default     = "%s"
  description = "This is using the format interpolation symbols to allow the value of the subnet_type_tag_key to be modified."
  type        = string
}

variable "max_subnet_count" {
  default     = 0
  description = "Sets the maximum amount of subnets to deploy. 0 will deploy a subnet for every provided availablility zone (in `availability_zones` variable) within the region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where subnets will be created (e.g. `vpc-aceb2723`)"
}

variable "igw_id" {
  type        = string
  description = "Internet Gateway ID the public route table will point to (e.g. `igw-9c26a123`)"
}

variable "cidr_block" {
  type        = string
  description = "Base CIDR block which will be divided into subnet CIDR blocks (e.g. `10.0.0.0/16`)"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones where subnets will be created"
}

variable "availability_zone_attribute_style" {
  type        = string
  default     = "short"
  description = "The style of Availability Zone code to use in tags and names. One of `full`, `short`, or `fixed`."
}

variable "vpc_default_route_table_id" {
  type        = string
  default     = ""
  description = "Default route table for public subnets. If not set, will be created. (e.g. `rtb-f4f0ce12`)"
}

variable "public_network_acl_id" {
  type        = string
  default     = ""
  description = "Network ACL ID that will be added to public subnets. If empty, a new ACL will be created"
}

variable "private_network_acl_id" {
  type        = string
  description = "Network ACL ID that will be added to private subnets. If empty, a new ACL will be created"
  default     = ""
}

variable "nat_gateway_enabled" {
  type        = bool
  description = "Flag to enable/disable NAT Gateways to allow servers in the private subnets to access the Internet"
  default     = true
}

variable "nat_instance_enabled" {
  type        = bool
  description = "Flag to enable/disable NAT Instances to allow servers in the private subnets to access the Internet"
  default     = false
}

variable "nat_instance_type" {
  type        = string
  description = "NAT Instance type"
  default     = "t3.micro"
}

variable "nat_elastic_ips" {
  type        = list(string)
  default     = []
  description = "Existing Elastic IPs to attach to the NAT Gateway(s) or Instance(s) instead of creating new ones."
}

variable "map_public_ip_on_launch" {
  type        = bool
  default     = true
  description = "Instances launched into a public subnet should be assigned a public IP address"
}

variable "aws_route_create_timeout" {
  type        = string
  default     = "2m"
  description = "Time to wait for AWS route creation specifed as a Go Duration, e.g. `2m`"
}

variable "aws_route_delete_timeout" {
  type        = string
  default     = "5m"
  description = "Time to wait for AWS route deletion specifed as a Go Duration, e.g. `5m`"
}

variable "private_subnets_additional_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to be added to private subnets"
}

variable "public_subnets_additional_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to be added to public subnets"
}

variable "metadata_http_endpoint_enabled" {
  type        = bool
  default     = true
  description = "Whether the metadata service is available"
}

variable "metadata_http_put_response_hop_limit" {
  type        = number
  default     = 1
  description = "The desired HTTP PUT response hop limit (between 1 and 64) for instance metadata requests."
}

variable "metadata_http_tokens_required" {
  type        = bool
  default     = true
  description = "Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2."
}

variable "root_block_device_encrypted" {
  type        = bool
  default     = true
  description = "Whether to encrypt the root block device"
}

variable "create_public_subnets" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating public subnets. Some of your CIDR block will still be reserved, so you can change this later without disruption."
}

variable "create_private_subnets" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating private subnets. Some of your CIDR block will still be reserved, so you can change this later without disruption."
}

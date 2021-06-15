<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_nat_instance_label"></a> [nat\_instance\_label](#module\_nat\_instance\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_nat_instance_security_group"></a> [nat\_instance\_security\_group](#module\_nat\_instance\_security\_group) | cloudposse/security-group/aws | 0.3.1 |
| <a name="module_nat_label"></a> [nat\_label](#module\_nat\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_private_label"></a> [private\_label](#module\_private\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_public_label"></a> [public\_label](#module\_public\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |
| <a name="module_utils"></a> [utils](#module\_utils) | cloudposse/utils/aws | 0.8.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eip.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.nat_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.nat_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.nat_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_nat_gateway.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_route.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_ami.nat_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eip.nat_ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eip) | data source |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_availability_zone_attribute_style"></a> [availability\_zone\_attribute\_style](#input\_availability\_zone\_attribute\_style) | The style of Availability Zone code to use in tags and names. One of `full`, `short`, or `fixed`. | `string` | `"short"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of Availability Zones where subnets will be created | `list(string)` | n/a | yes |
| <a name="input_aws_route_create_timeout"></a> [aws\_route\_create\_timeout](#input\_aws\_route\_create\_timeout) | Time to wait for AWS route creation specifed as a Go Duration, e.g. `2m` | `string` | `"2m"` | no |
| <a name="input_aws_route_delete_timeout"></a> [aws\_route\_delete\_timeout](#input\_aws\_route\_delete\_timeout) | Time to wait for AWS route deletion specifed as a Go Duration, e.g. `5m` | `string` | `"5m"` | no |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | Base CIDR block which will be divided into subnet CIDR blocks (e.g. `10.0.0.0/16`) | `string` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_igw_id"></a> [igw\_id](#input\_igw\_id) | Internet Gateway ID the public route table will point to (e.g. `igw-9c26a123`) | `string` | n/a | yes |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | Instances launched into a public subnet should be assigned a public IP address | `bool` | `true` | no |
| <a name="input_max_subnet_count"></a> [max\_subnet\_count](#input\_max\_subnet\_count) | Sets the maximum amount of subnets to deploy. 0 will deploy a subnet for every provided availablility zone (in `availability_zones` variable) within the region | `number` | `0` | no |
| <a name="input_metadata_http_endpoint_enabled"></a> [metadata\_http\_endpoint\_enabled](#input\_metadata\_http\_endpoint\_enabled) | Whether the metadata service is available | `bool` | `true` | no |
| <a name="input_metadata_http_put_response_hop_limit"></a> [metadata\_http\_put\_response\_hop\_limit](#input\_metadata\_http\_put\_response\_hop\_limit) | The desired HTTP PUT response hop limit (between 1 and 64) for instance metadata requests. | `number` | `1` | no |
| <a name="input_metadata_http_tokens_required"></a> [metadata\_http\_tokens\_required](#input\_metadata\_http\_tokens\_required) | Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_nat_elastic_ips"></a> [nat\_elastic\_ips](#input\_nat\_elastic\_ips) | Existing Elastic IPs to attach to the NAT Gateway(s) or Instance(s) instead of creating new ones. | `list(string)` | `[]` | no |
| <a name="input_nat_gateway_enabled"></a> [nat\_gateway\_enabled](#input\_nat\_gateway\_enabled) | Flag to enable/disable NAT Gateways to allow servers in the private subnets to access the Internet | `bool` | `true` | no |
| <a name="input_nat_instance_enabled"></a> [nat\_instance\_enabled](#input\_nat\_instance\_enabled) | Flag to enable/disable NAT Instances to allow servers in the private subnets to access the Internet | `bool` | `false` | no |
| <a name="input_nat_instance_type"></a> [nat\_instance\_type](#input\_nat\_instance\_type) | NAT Instance type | `string` | `"t3.micro"` | no |
| <a name="input_private_network_acl_id"></a> [private\_network\_acl\_id](#input\_private\_network\_acl\_id) | Network ACL ID that will be added to private subnets. If empty, a new ACL will be created | `string` | `""` | no |
| <a name="input_private_subnets_additional_tags"></a> [private\_subnets\_additional\_tags](#input\_private\_subnets\_additional\_tags) | Additional tags to be added to private subnets | `map(string)` | `{}` | no |
| <a name="input_public_network_acl_id"></a> [public\_network\_acl\_id](#input\_public\_network\_acl\_id) | Network ACL ID that will be added to public subnets. If empty, a new ACL will be created | `string` | `""` | no |
| <a name="input_public_subnets_additional_tags"></a> [public\_subnets\_additional\_tags](#input\_public\_subnets\_additional\_tags) | Additional tags to be added to public subnets | `map(string)` | `{}` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_root_block_device_encrypted"></a> [root\_block\_device\_encrypted](#input\_root\_block\_device\_encrypted) | Whether to encrypt the root block device | `bool` | `true` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | The Security Group description. | `string` | `"Security Group for NAT Instance"` | no |
| <a name="input_security_group_enabled"></a> [security\_group\_enabled](#input\_security\_group\_enabled) | Whether to create default Security Group for NAT Instance. | `bool` | `true` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | A list of maps of Security Group rules. <br>The values of map is fully complated with `aws_security_group_rule` resource. <br>To get more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule .<br><br>By default it creates rules which are allows all `egress` trafic and all ingress from the `vpc_cidr`. | `list(any)` | `[]` | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Whether to create a default Security Group with unique name beginning with the normalized prefix. | `bool` | `false` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of Security Group IDs to associate with NAT Instance. | `list(string)` | `[]` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnet_type_tag_key"></a> [subnet\_type\_tag\_key](#input\_subnet\_type\_tag\_key) | Key for subnet type tag to provide information about the type of subnets, e.g. `cpco.io/subnet/type=private` or `cpco.io/subnet/type=public` | `string` | `"cpco.io/subnet/type"` | no |
| <a name="input_subnet_type_tag_value_format"></a> [subnet\_type\_tag\_value\_format](#input\_subnet\_type\_tag\_value\_format) | This is using the format interpolation symbols to allow the value of the subnet\_type\_tag\_key to be modified. | `string` | `"%s"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_vpc_default_route_table_id"></a> [vpc\_default\_route\_table\_id](#input\_vpc\_default\_route\_table\_id) | Default route table for public subnets. If not set, will be created. (e.g. `rtb-f4f0ce12`) | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where subnets will be created (e.g. `vpc-aceb2723`) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | List of Availability Zones where subnets were created |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | IDs of the NAT Gateways created |
| <a name="output_nat_gateway_public_ips"></a> [nat\_gateway\_public\_ips](#output\_nat\_gateway\_public\_ips) | EIP of the NAT Gateway |
| <a name="output_nat_instance_ids"></a> [nat\_instance\_ids](#output\_nat\_instance\_ids) | IDs of the NAT Instances created |
| <a name="output_nat_instance_security_group_arn"></a> [nat\_instance\_security\_group\_arn](#output\_nat\_instance\_security\_group\_arn) | NAT Instance Security Group ARN |
| <a name="output_nat_instance_security_group_id"></a> [nat\_instance\_security\_group\_id](#output\_nat\_instance\_security\_group\_id) | NAT Instance Security Group ID |
| <a name="output_nat_instance_security_group_name"></a> [nat\_instance\_security\_group\_name](#output\_nat\_instance\_security\_group\_name) | NAT Instance Security Group name |
| <a name="output_nat_ips"></a> [nat\_ips](#output\_nat\_ips) | IP Addresses in use for NAT |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | IDs of the created private route tables |
| <a name="output_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#output\_private\_subnet\_cidrs) | CIDR blocks of the created private subnets |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the created private subnets |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | IDs of the created public route tables |
| <a name="output_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#output\_public\_subnet\_cidrs) | CIDR blocks of the created public subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the created public subnets |
<!-- markdownlint-restore -->

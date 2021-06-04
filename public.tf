module "public_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = ["public"]
  tags = merge(
    var.public_subnets_additional_tags,
    { (var.subnet_type_tag_key) = format(var.subnet_type_tag_value_format, "public") }
  )

  context = module.this.context
}

locals {
  public_enabled             = local.enabled && var.create_public_subnets
  public_subnet_count        = local.public_enabled && var.max_subnet_count == 0 ? length(flatten(data.aws_availability_zones.available.*.names)) : var.max_subnet_count
  public_route_expr_enabled  = signum(length(var.vpc_default_route_table_id)) == 1
  public_network_acl_enabled = local.public_enabled && signum(length(var.public_network_acl_id)) == 0 ? 1 : 0
  vpc_default_route_table_id = local.public_enabled ? signum(length(var.vpc_default_route_table_id)) : 0
}

resource "aws_subnet" "public" {
  count             = local.public_enabled ? local.availability_zones_count : 0
  vpc_id            = join("", data.aws_vpc.default.*.id)
  availability_zone = element(var.availability_zones, count.index)

  cidr_block = cidrsubnet(
    signum(length(var.cidr_block)) == 1 ? var.cidr_block : join("", data.aws_vpc.default.*.cidr_block),
    ceil(log(local.public_subnet_count * 2, 2)),
    local.public_subnet_count + count.index
  )

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    module.public_label.tags,
    {
      "Name" = format("%s%s%s", module.public_label.id, local.delimiter, local.az_map[element(var.availability_zones, count.index)])
    }
  )

  lifecycle {
    ignore_changes = [tags.kubernetes, tags.SubnetType]
  }
}

resource "aws_route_table" "public" {
  count  = local.public_route_expr_enabled ? 0 : local.enabled_count
  vpc_id = join("", data.aws_vpc.default.*.id)

  tags = module.public_label.tags
}

resource "aws_route" "public" {
  count                  = local.public_route_expr_enabled ? 0 : local.enabled_count
  route_table_id         = join("", aws_route_table.public.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id

  timeouts {
    create = var.aws_route_create_timeout
    delete = var.aws_route_delete_timeout
  }
}

resource "aws_route_table_association" "public" {
  count          = local.public_enabled ? (local.public_route_expr_enabled ? 0 : local.availability_zones_count) : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "public_default" {
  count          = local.public_enabled ? (local.public_route_expr_enabled ? local.availability_zones_count : 0) : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = var.vpc_default_route_table_id
}

resource "aws_network_acl" "public" {
  count      = local.public_network_acl_enabled
  vpc_id     = var.vpc_id
  subnet_ids = aws_subnet.public.*.id

  egress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  ingress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  tags = module.public_label.tags
}

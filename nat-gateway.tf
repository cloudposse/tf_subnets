module "nat_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = ["nat"]

  context = module.this.context
}

locals {
  nat_gateway_eip_count   = local.use_existing_eips ? 0 : local.nat_gateways_count
  gateway_eip_allocations = local.use_existing_eips ? data.aws_eip.nat_ips.*.id : aws_eip.default.*.id
  eips_allocations        = local.use_existing_eips ? data.aws_eip.nat_ips.*.id : aws_eip.default.*.id
  nat_gateways_count      = var.nat_gateway_enabled ? length(var.availability_zones) : 0
}

resource "aws_eip" "default" {
  count = local.public_enabled ? local.nat_gateway_eip_count : 0
  vpc   = true

  tags = merge(
    module.private_label.tags,
    {
      "Name" = format("%s%s%s", module.private_label.id, local.delimiter, local.az_map[element(var.availability_zones, count.index)])
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "default" {
  count         = local.public_enabled ? local.nat_gateways_count : 0
  allocation_id = element(local.gateway_eip_allocations, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    module.nat_label.tags,
    {
      "Name" = format("%s%s%s", module.nat_label.id, local.delimiter, local.az_map[element(var.availability_zones, count.index)])
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route" "default" {
  count                  = local.public_enabled ? local.nat_gateways_count : 0
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.default.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private]

  timeouts {
    create = var.aws_route_create_timeout
    delete = var.aws_route_delete_timeout
  }
}

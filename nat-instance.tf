module "nat_instance_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = ["nat", "instance"]

  context = module.this.context
}

locals {
  cidr_block               = var.cidr_block != "" ? var.cidr_block : join("", data.aws_vpc.default.*.cidr_block)
  nat_instance_enabled     = var.nat_instance_enabled ? 1 : 0
  nat_instance_count       = var.nat_instance_enabled ? length(var.availability_zones) : 0
  nat_instance_eip_count   = local.use_existing_eips ? 0 : local.nat_instance_count
  instance_eip_allocations = local.use_existing_eips ? data.aws_eip.nat_ips.*.id : aws_eip.nat_instance.*.id
}

resource "aws_security_group" "nat_instance" {
  count       = local.public_enabled ? local.nat_instance_enabled : 0
  name        = module.nat_instance_label.id
  description = "Security Group for NAT Instance"
  vpc_id      = var.vpc_id
  tags        = module.nat_instance_label.tags
}

resource "aws_security_group_rule" "nat_instance_egress" {
  count             = local.public_enabled ? local.nat_instance_enabled : 0
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  security_group_id = join("", aws_security_group.nat_instance.*.id)
  type              = "egress"
}

resource "aws_security_group_rule" "nat_instance_ingress" {
  count             = local.public_enabled ? local.nat_instance_enabled : 0
  description       = "Allow ingress traffic from the VPC CIDR block"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [local.cidr_block]
  security_group_id = join("", aws_security_group.nat_instance.*.id)
  type              = "ingress"
}

# aws --region us-west-2 ec2 describe-images --owners amazon --filters Name="name",Values="amzn-ami-vpc-nat*" Name="virtualization-type",Values="hvm"
data "aws_ami" "nat_instance" {
  count       = local.public_enabled ? local.nat_instance_enabled : 0
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-comparison.html
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html
# https://dzone.com/articles/nat-instance-vs-nat-gateway
resource "aws_instance" "nat_instance" {
  count                  = local.public_enabled ? local.nat_instance_count : 0
  ami                    = join("", data.aws_ami.nat_instance.*.id)
  instance_type          = var.nat_instance_type
  subnet_id              = element(aws_subnet.public.*.id, count.index)
  vpc_security_group_ids = [aws_security_group.nat_instance[0].id]

  tags = merge(
    module.nat_instance_label.tags,
    {
      "Name" = format("%s%s%s", module.nat_instance_label.id, local.delimiter, local.az_map[element(var.availability_zones, count.index)])
    }
  )

  # Required by NAT
  # https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html#EIP_Disable_SrcDestCheck
  source_dest_check = false

  #bridgecrew:skip=BC_AWS_PUBLIC_12: Skipping `EC2 Should Not Have Public IPs` check. NAT instance requires public IP.
  #bridgecrew:skip=BC_AWS_GENERAL_31: Skipping `Ensure Instance Metadata Service Version 1 is not enabled` check until BridgeCrew support condition evaluation. See https://github.com/bridgecrewio/checkov/issues/793
  associate_public_ip_address = true #tfsec:ignore:AWS012

  lifecycle {
    create_before_destroy = true
  }

  metadata_options {
    http_endpoint               = (var.metadata_http_endpoint_enabled) ? "enabled" : "disabled"
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    http_tokens                 = (var.metadata_http_tokens_required) ? "required" : "optional"
  }

  root_block_device {
    encrypted = var.root_block_device_encrypted
  }
}

resource "aws_eip" "nat_instance" {
  count = local.public_enabled ? local.nat_instance_eip_count : 0
  vpc   = true
  tags = merge(
    module.nat_instance_label.tags,
    {
      "Name" = format("%s%s%s", module.nat_instance_label.id, local.delimiter, local.az_map[element(var.availability_zones, count.index)])
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "nat_instance" {
  count         = local.public_enabled ? local.nat_instance_count : 0
  instance_id   = element(aws_instance.nat_instance.*.id, count.index)
  allocation_id = element(local.instance_eip_allocations, count.index)
}

resource "aws_route" "nat_instance" {
  count                  = local.public_enabled ? local.nat_instance_count : 0
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  instance_id            = element(aws_instance.nat_instance.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private]

  timeouts {
    create = var.aws_route_create_timeout
    delete = var.aws_route_delete_timeout
  }
}

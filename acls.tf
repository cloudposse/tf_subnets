module "acl_public_label" {
  source     = "git::https://github.com/cloudposse/tf_label.git?ref=tags/0.2.0"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = ["public"]
  tags       = "${var.tags}"
}

module "acl_private_label" {
  source     = "git::https://github.com/cloudposse/tf_label.git?ref=tags/0.2.0"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = ["private"]
  tags       = "${var.tags}"
}

resource "aws_network_acl" "public" {
  count      = "${signum(length(var.public_network_acl_id)) == 0 ? 1 : 0}"
  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["${aws_subnet.public.*.id}"]

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

  tags = "${module.acl_public_label.tags}"
}

resource "aws_network_acl" "private" {
  count      = "${signum(length(var.private_network_acl_id)) == 0 ? 1 : 0}"
  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["${aws_subnet.private.*.id}"]

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

  tags = "${module.acl_private_label.tags}"
}
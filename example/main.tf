## This example demonstrates it use as if it was being used 
## for some Spinnaker (spinnaker.io) deployment
module "dynamic_subnets" {
  source                  = "./.."
  context                 = "${module.label.context}"
  tags                    = "${merge(module.label.tags, local.subnet_tags)}"
  region                  = "${data.aws_region.current.name}"
  availability_zones      = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b"] // Optional list of AZ's to restrict it to
  vpc_id                  = "${module.vpc.vpc_id}"
  igw_id                  = "${module.vpc.igw_id}"
  public_subnet_count     = "2"                                                                      // Two public zones for the load balancers
  private_subnet_count    = "4"                                                                      // Four private zones for the 
  map_public_ip_on_launch = "true"

  ## Optionally customising a tag based on whether it is public or private
  ## will format like this: "immutable_metadata": {"purpose": \"public-subnet\"}"
  subnet_type_tag_key = "immutable_metadata"

  subnet_type_tag_value_format = "{\"purpose\": \"%s-subnet\"}" // The %s gets replaced with 'public' on public subnets and 'private' on private subnets
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.4.1"
  namespace  = "${module.label.namespace}"
  stage      = "${module.label.environment}"
  name       = "${module.label.name}"
  attributes = ["${module.label.attributes}"]
  delimiter  = "${module.label.delimiter}"
  tags       = "${module.label.tags}"
  cidr_block = "${var.vpc_cidr}"
}

data "aws_region" "current" {}

module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  namespace   = "cp"
  environment = "prod"
  delimiter   = "-"
  name        = "app"

  tags = {
    "ManagedBy" = "Terraform"
    "ModuleBy"  = "CloudPosse"
  }
}

variable "eks_cluster_name" {
  default = "my-main-eks-cluster"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

locals {
  # Spinnaker subnet tags
  subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = ""
    "kubernetes.io/role/internal-elb"               = ""
  }
}

provider "aws" {
  version = "~> 2.13"
  region  = "eu-west-2"
}

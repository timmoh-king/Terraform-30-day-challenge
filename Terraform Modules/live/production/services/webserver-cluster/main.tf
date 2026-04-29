# live/production/services/webserver-cluster/main.tf

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "webserver_cluster" {
  source = "../../../../modules/services/webserver-cluster"

  cluster_name  = "webservers-production"
  instance_type = "t2.medium"
  min_size      = 4
  max_size      = 10
  vpc_id        = coalesce(var.vpc_id, data.aws_vpc.default.id)
  subnet_ids    = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.default.ids
}

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
  source = "github.com/timmoh-king/Terraform-30-day-challenge?ref=v0.0.2"

  cluster_name  = "webservers-dev"
  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 4
  vpc_id        = coalesce(var.vpc_id, data.aws_vpc.default.id)
  subnet_ids    = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.default.ids
}

output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}

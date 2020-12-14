data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "foo.terraform.backend"
    key    = "internal/aws-infrastructure.tfstate"
    region = "us-east-1"
  }
}

data "aws_vpc" "selected" {
  id = data.terraform_remote_state.vpc.outputs.foobar_tunnel_vpc_id
}


locals {
  vpc_id            = data.aws_vpc.selected.id
  vpc_cidr_block    = data.aws_vpc.selected.cidr_block
  subnet_id         = data.terraform_remote_state.vpc.outputs.foobar_tunnel_public_subnet_ids[0]
  subnet_cidr_block = data.terraform_remote_state.vpc.outputs.foobar_tunnel_public_subnet_cidrblocks[0]
  public_subnets    = data.terraform_remote_state.vpc.outputs.foobar_tunnel_public_subnet_ids
  vpn_routes_tables = flatten([
    for table in data.aws_route_tables.selected.ids : [
      for route in var.vpn_remote_nets : {
        table_id   = table
        remote_net = route
      }
    ]
  ])
}

data "aws_route_tables" "selected" {
  vpc_id = local.vpc_id
}

resource "aws_route" "vpn_routes" {
  count = length(local.vpn_routes_tables)
  //noinspection HILUnresolvedReference
  route_table_id = local.vpn_routes_tables[count.index].table_id
  //noinspection HILUnresolvedReference
  destination_cidr_block = local.vpn_routes_tables[count.index].remote_net
  network_interface_id   = aws_network_interface.awsvpn_gw_eni.id
}
variable "aws_profile" {
  description = ".aws/credentials profile being used to setup this environment, change in main.tf also"
  default     = "foobar"
}

variable "region_azs" {
  description = "The AZs for the various regions. It's always a good idea to define these to make sure they are being used. You should be able to extend these out as we need more and more regions."
  type        = map(list(string))

  default = {
    us-west-1 = ["us-west-1a", "us-west-1b", "us-west-1c"]
  }
}

variable "environment" {
  // From the CLI.
  description = "This is a tag to use that is appended to almost everything denoting which environment that this object relates."
  default     = "foo-tunnel"
}

variable "aws_region" {
  description = "AWS region."
  default     = "us-west-1"
}

variable "enable_awsvpn" {
  default = "true"
}
#
variable "instance_types" {
  default = [
    "awsvpn"
  ]
}

variable "enable_novpnalarm" {
  default = "false"
}

variable "awsvpn_instance_type" {
  default = "m5.large"
}

variable "bashdebug" {
  description = "Turn on debugging on bash scripts 1 or 0"
  default     = "0"
}

variable "keepalivedpriorities" {
  type    = list(string)
  default = ["150", "100"]
}

variable "keepalivedrole" {
  type    = list(string)
  default = ["VPN-Master", "VPN-Backup"]
}

variable "defaultdev" {
  type        = string
  description = "The interface name for the default network interface on the instances (e.g. ens5 or eth0)"
  default     = "eth0"
}

variable "gw_enidev" {
  type        = string
  description = "The interface name for the ENI attached (virtual) interface on the instances"
  default     = "eth1"
}

variable "nat_enidev" {
  type        = string
  description = "The interface name for the ENI attached (virtual) interface on the instances"
  default     = "eth2"
}

variable "vpn_remote_nets" {
  type        = list(string)
  description = "CIDR blocks of remote side networks for routing to the VPN servers from VPC subnets"
  default = [
    "10.50.0.0/24",
    "172.16.201.0/24",
    "192.168.110.0/24",
    "172.16.1.0/24",
    "192.168.1.0/24",
    "192.168.2.0/24",
    "192.168.112.0/24",
    "192.168.151.0/24",
    "10.41.80.24/32",
    "10.48.0.0/12",
    "54.145.10.34/32",
    "54.160.141.237/32",
    "54.87.35.77/32",
    "65.197.201.0/24",
    "199.164.215.0/24",
    "10.10.0.0/24"
  ]
}

variable "route53_zone" {
  type        = string
  description = "Route53 Zone"
  default     = "Z1DUFI5ARWZQ5R"
}

variable "company_name" {
  type        = string
  description = "Name of company"
  default     = "foobar"
}

variable "syscontact" {
  type        = string
  description = "SNMP Syscontact"
  default     = "corpit@foobar.com"
}

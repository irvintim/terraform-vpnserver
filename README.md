AWS VPN Terraform module
===========

This module will configure 2 redundant VPN servers at AWS that will run both libreswan (IPSEC) and OpenVPN servers using Keepalived to manage the redundancy.   

# Setup

The servers and accompanied AWS infrastructure are created with Terraform.  This module attempts to mimic the current Foobar db-dev terraform configuration, and this envionment is setup within the db-dev VPC.  Foobar IT staff (in conjunction with NetTempo, as needed) may decide to merge this code into the current db-dev and prod terraform code.

Currently, to link this infrastructure with the current db-dev (or prod) infrastructure, the subnet ID for one of the public subnets in the db-dev VPC is hardcoded in the `dev-us-east-2/vpc/vpc.tf` file, as follows:
```hcl-terraform
variable "public_subnet_id" {
  default = "subnet-048d56a82518aae36"
}
```
Ideally, the Remote State from the current VPC would export additional details and this file can be updated to glean the info automatically.
Alternatively, this module might be merged into the current db-dev module and be deployed with that terraform code.

Currently, all variables in `dev-us-east-2/vpc/variables.tf` are set for the `db-dev` development environment.  These variables can be changed for production by either copying this module to a new directory structure (similar to the current Foobar infrastructure), or using `-var` flags to the `terraform plan`.

In addition to the `public_subnet_id` variable discussed above, the additional important variables are:
```hcl-terraform
variable "aws_profile" {
    description = ".aws/credentials profile being used to setup this environment, change in main.tf also"
    default     = "default"
}

variable "region_azs" {
  description = "The AZs for the various regions. It's always a good idea to define these to make sure they are being used. You should be able to extend these out as we need more and more regions."
  type = map(list(string))

  default = {
    us-east-2 = ["us-east-2a", "us-east-2b", "us-east-2c"]
  }
}

variable "environment" {
    // From the CLI.
    description = "This is a tag to use that is appended to almost everything denoting which environment that this object relates."
    default     = "db-dev"
}

variable "aws_region" {
  description = "AWS region."
  default     = "us-east-2"
}

variable "awsvpn_instance_type" {
  default = "m5n.large"
}

variable "vpn_remote_nets" {
  type = list(string)
  description = "CIDR blocks of remote side networks for routing to the VPN servers from VPC subnets"
  default = [ "11.10.0.0/24" ]
}
```

Some additional variables/parameters are stored in the AWS SSM Parameter Store (in the same region as the environment), these will need to be configured prior to building the environment:
* /foobar/awsvpn/db-dev/snmprocommunity: SNMP Read-Only Community String on the VPN servers
* /foobar/awsvpn/db-dev/snmprwcommunity: SNMP Read-Write Community String on the VPN servers
* /foobar/awsvpn/db-dev/togglematch: A secret key used to authenticate requests to the "Keepalived" toggle web interface
* /foobar/awsvpn/db-dev/toggleport: The port that the Keepalived toggle web interface listens on
* /foobar/global/db-dev/sshkey : SSH Keypair for the "centos" user


To setup the environment run:
```shell script
terraform init
terraform plan -out terraform.tfplan
terraform apply terraform.tfplan
```
 
## Components

The following AWS components are installed and configured:

* EC2 Instances: 2 instances are provisioned within the public subnet specified in `vpc.tf`
* Elastic Network Interface: An ENI is setup with an Elastic IP (public IP/EIP).  This ENI is migrated by the Keepalived software to the active VPN server, and all IPSEC/OpenVPN traffic is sent through this network interface.
* SNS Topic: The SNS topic `db-dev-aws-vpnalarms` has been setup to alert on various events, like Keepalived failover.
* SSM Parameters: The internal IPs of the two instances are stored in SSM parameters (`/foobar/awsvpn/db-dev/backup_ip`, and `/foobar/awsvpn/db-dev/backup_ip`) to be used by puppet in configuring keepalived.
* Cloudwatch Logs: Important daemon logs are send using hte Cloudwatch agent to the CloudWatch loggroup `/foobar/awsvpn/var/log/tocloudwatch.log`.
* Cloudwatch Metrics: Using Cloudwatch Agent, along with collectd, snmpd, and other plugins -- extensive amount of metric data are sent to Cloudwatch.  This data can be utilized to monitor and alarm on situations/events.  Most of this data will be found in the `CWAgent` Namespace.
* Cloudwatch Dashboard: A dashboard has been configured to allow monitoring of the Keepalived, OpenVPN, and Libreswan services.  It also contains a "Toggle" button that will cause the Keepalived servers to swap roles.  (https://us-east-2.console.aws.amazon.com/cloudwatch/home?region=us-east-2#dashboards:name=AWS-VPN_Dashboard_db-dev;autoRefresh=10)
* Routes:  Routes are added to all the Routing Tables in the VPC, for routes to the IPSEC far-end networks via the ENI interface.  These routes are configured in `variables.tf` with the following variable: 
```hcl-terraform
variable "vpn_remote_nets" {
  type = list(string)
  description = "CIDR blocks of remote side networks for routing to the VPN servers from VPC subnets"
  default = [ "10.10.0.0/24" ]
}
```
* Security Groups/IAM Roles: Various SGs and Roles to allow for the services to function.

## To do

* Route53:  The public and private IPs of the instances and the ENI that is shared should be added to Foobar's current Route53 service.
* OpenVPN config: The current OpenVPN config is a copy of the OpenVPN service in the UK, it is not functional right now.  It will either need to be worked on, or replaced with a new configuration.
* Libreswan: A method of automation to maintain the Libreswan configuration was out of scope of this project.  There is a sample config for the test VPN at NetTempo in the puppet configs, however that sample stores pre-shared secrets in Git, which is not advised.
* Cloudwatch Alarms:  A sample Cloudwatch alarm that will send notifications to the SNS Topic `db-dev-aws-vpnalarms`i when IPSEC sessions reach 0, indicating an issue with the Libreswan environment, is included in the `cloudwatch.tf` file.  However, that config gives an AWS SDK error that has not been resolved.  Similar alarms should likely be setup, and hopefully terraformed if the SDK error can be fixed.
* SNS Topic:  Email and SMS subscribers will need to be added to the SNS Topic in order to receive alerts.

# Current configuration

* Public IP for the ENI: 3.23.226.245




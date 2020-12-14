resource "aws_security_group" "awsvpn_instance_security_group" {
  name        = "${var.environment}-awsvpn-instance"
  description = "AWSVPN Instance Allowed Ports-${var.environment}"
  vpc_id      = local.vpc_id
  tags = merge(
    local.global_tags,
  map("Name", "${var.environment}-awsvpn-instance"))
}

resource "aws_security_group_rule" "awsvpn_instance_sg_togglelistener" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = data.aws_ssm_parameter.toggle_port.value
  to_port           = data.aws_ssm_parameter.toggle_port.value
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.awsvpn_instance_security_group.id
  description       = "Listener for keepalived web toggler"
}

resource "aws_security_group_rule" "awsvpn_instance_sg_sshaccess" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = [local.vpc_cidr_block]
  security_group_id = aws_security_group.awsvpn_instance_security_group.id
  description       = "SSH Access from VPC"
}

resource "aws_security_group_rule" "awsvpn_instance_sg_vrrp" {
  type              = "ingress"
  protocol          = 112
  from_port         = -1
  to_port           = -1
  cidr_blocks       = [local.subnet_cidr_block]
  security_group_id = aws_security_group.awsvpn_instance_security_group.id
  description       = "Keepalived VRRP (112) heartbeat between failover pair"
}

resource "aws_security_group_rule" "awsvpn_instance_sg_icmp" {
  type              = "ingress"
  protocol          = "ICMP"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.awsvpn_instance_security_group.id
  description       = "Allow ICMP (ping) -- could be tightened"
}

resource "aws_security_group_rule" "awsvpn_instance_sg_ssh" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["24.205.198.194/32", "45.29.138.49/32", "136.25.104.204/32", "73.93.244.239/32", "70.186.107.41/32"]
  security_group_id = aws_security_group.awsvpn_instance_security_group.id
  description       = "SSH Access from NetTempo networks -- to be removed"
}

resource "aws_security_group_rule" "awsvpn_instance_sg_foobar_ssh" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["10.100.0.0/16"]
  security_group_id = aws_security_group.awsvpn_instance_security_group.id
  description       = "SSH Access from Foobar networks"
}

resource "aws_security_group_rule" "awsvpn_instance_sg_foobar_dns_tcp" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 53
  to_port           = 53
  cidr_blocks       = ["10.100.0.0/16"]
  security_group_id = aws_security_group.awsvpn_instance_security_group.id
  description       = "DNS Access from Foobar networks"
}

resource "aws_security_group_rule" "awsvpn_instance_sg_foobar_dns_udp" {
  type              = "ingress"
  protocol          = "udp"
  from_port         = 53
  to_port           = 53
  cidr_blocks       = ["10.100.0.0/16"]
  security_group_id = aws_security_group.awsvpn_instance_security_group.id
  description       = "DNS Access from Foobar networks"
}

resource "aws_security_group_rule" "awsvpn_instance_egress_all" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.awsvpn_instance_security_group.id
}

resource "aws_security_group" "awsvpn_gw_eni_security_group" {
  name        = "${var.environment}-awsvpn-gw-eni"
  description = "AWSVPN GW ENI Allowed Ports-${var.environment}"
  vpc_id      = local.vpc_id
  tags = merge(
    local.global_tags,
  map("Name", "${var.environment}-awsvpn-gw-eni"))
}

resource "aws_security_group_rule" "awsvpn_gw_eni_sg_libreswan_500" {
  type              = "ingress"
  protocol          = "udp"
  from_port         = 500
  to_port           = 500
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.awsvpn_gw_eni_security_group.id
  description       = "Libreswan port 500 Access to GW ENI Virtual IP"
}

resource "aws_security_group_rule" "awsvpn_gw_eni_sg_libreswan_4500" {
  type              = "ingress"
  protocol          = "udp"
  from_port         = 4500
  to_port           = 4500
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.awsvpn_gw_eni_security_group.id
  description       = "Libreswan port 500 Access to GW ENI Virtual IP"
}

resource "aws_security_group_rule" "awsvpn_gw_eni_sg_icmp" {
  type              = "ingress"
  protocol          = "ICMP"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.awsvpn_gw_eni_security_group.id
  description       = "Allow ICMP (ping) -- could be tightened"
}

resource "aws_security_group_rule" "awsvpn_gw_eni_egress_all" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.awsvpn_gw_eni_security_group.id
}
resource "aws_security_group" "awsvpn_nat_eni_security_group" {
  name        = "${var.environment}-awsvpn-nat-eni"
  description = "AWSVPN NAT ENI Allowed Ports-${var.environment}"
  vpc_id      = local.vpc_id
  tags = merge(
    local.global_tags,
  map("Name", "${var.environment}-awsvpn-nat-eni"))
}

resource "aws_security_group_rule" "awsvpn_nat_eni_sg_icmp" {
  type              = "ingress"
  protocol          = "ICMP"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.awsvpn_nat_eni_security_group.id
  description       = "Allow ICMP (ping) -- could be tightened"
}

resource "aws_security_group_rule" "awsvpn_nat_eni_egress_all" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.awsvpn_nat_eni_security_group.id
}

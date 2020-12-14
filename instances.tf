# ----------------------------------------------------
# Instances
# ----------------------------------------------------

# --------------------------
# AMI - Amazon Linux 2
# --------------------------
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_network_interface" "awsvpn_gw_eni" {
  subnet_id         = local.subnet_id
  security_groups   = [aws_security_group.awsvpn_gw_eni_security_group.id]
  source_dest_check = false
  tags              = merge(local.global_tags)
}

resource "aws_eip" "awsvpn_gw_eni_eip" {
  vpc               = true
  network_interface = aws_network_interface.awsvpn_gw_eni.id
  lifecycle {
    prevent_destroy = true
  }
  tags = merge(local.global_tags,
  map("Name", "${var.environment}-awsvpn-GW"))
}

resource "aws_network_interface" "awsvpn_nat_eni" {
  subnet_id         = local.subnet_id
  security_groups   = [aws_security_group.awsvpn_nat_eni_security_group.id]
  source_dest_check = false
  tags              = merge(local.global_tags)
}

resource "aws_eip" "awsvpn_nat_eni_eip" {
  vpc               = true
  network_interface = aws_network_interface.awsvpn_nat_eni.id
  lifecycle {
    prevent_destroy = true
  }
  tags = merge(local.global_tags,
  map("Name", "${var.environment}-awsvpn-NAT"))
}

resource "aws_instance" "awsvpn" {
  count                       = var.enable_awsvpn ? 2 : 0
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.awsvpn_instance_type
  key_name                    = var.environment
  vpc_security_group_ids      = [aws_security_group.awsvpn_instance_security_group.id]
  subnet_id                   = local.public_subnets[0]
  associate_public_ip_address = true
  source_dest_check           = false
  iam_instance_profile        = aws_iam_instance_profile.awsvpn_profile.name
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = "true"
  }

  user_data  = data.template_cloudinit_config.awsvpn_user_data[count.index].rendered
  depends_on = [aws_s3_bucket_object.ipsec_updown_netkey]

  tags = merge(
    local.global_tags,
    map("Name", "${var.environment}-awsvpn-${count.index + 1}",
  "KeepalivedRole", var.keepalivedrole[count.index]))
}



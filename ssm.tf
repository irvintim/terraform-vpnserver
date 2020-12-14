data "aws_ssm_parameter" "snmp_ro_community" {
  name = "/${var.company_name}/awsvpn/${local.ssm_environment}/snmprocommunity"
}

data "aws_ssm_parameter" "snmp_rw_community" {
  name = "/${var.company_name}/awsvpn/${local.ssm_environment}/snmprwcommunity"
}

data "aws_ssm_parameter" "toggle_port" {
  name = "/${var.company_name}/awsvpn/${local.ssm_environment}/toggleport"
}

data "aws_ssm_parameter" "toggle_match" {
  name = "/${var.company_name}/awsvpn/${local.ssm_environment}/togglematch"
}

resource "aws_ssm_parameter" "master_ip" {
  name  = "/${var.company_name}/awsvpn/${local.ssm_environment}/master_ip"
  type  = "String"
  value = aws_instance.awsvpn.0.private_ip
}

resource "aws_ssm_parameter" "backup_ip" {
  name  = "/${var.company_name}/awsvpn/${local.ssm_environment}/backup_ip"
  type  = "String"
  value = aws_instance.awsvpn.1.private_ip
}


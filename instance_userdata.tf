data "template_cloudinit_config" "awsvpn_user_data" {
  count         = var.enable_awsvpn ? 2 : 0
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.user_data_awsvpn_sh[count.index].rendered
  }

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.vpn_cloud_config_yml[count.index].rendered
  }
}

data "template_file" "user_data_awsvpn_sh" {
  count = var.enable_awsvpn ? 2 : 0

  template = file("${path.module}/templates/user-data-awsvpn.sh.tpl")
  vars = {
    environment         = var.environment
    aws_region          = var.aws_region
    hostname            = "awsvpn-${count.index + 1}"
    companyname         = var.company_name
    ipsec_updown_netkey = "s3://${aws_s3_bucket.awsvpn-provisioning-scripts.bucket}/${aws_s3_bucket_object.ipsec_updown_netkey.key}"
    ssmpath             = "/${var.company_name}/awsvpn/${local.ssm_environment}"
    dnsmasq_config_path = "s3://${aws_s3_bucket.awsvpn-provisioning-scripts.bucket}/files/etc/dnsmasq.d"
  }
}

data "template_file" "vpn_cloud_config_yml" {
  count = var.enable_awsvpn ? 2 : 0

  template = file("${path.module}/templates/cloud-config-yml.tpl")
  vars = {
    file_sysconfig_pluto_updown                              = base64gzip(file("${path.module}/files/etc/sysconfig/pluto_updown"))
    file_selinux_config                                      = base64gzip(file("${path.module}/files/etc/selinux/config"))
    file_system_keepalive_toggle_service                     = base64gzip(file("${path.module}/files/etc/systemd/system/keepalive-toggle.service"))
    file_keepalived_eni_sh                                   = base64gzip(file("${path.module}/files/opt/keepalived/eni.sh"))
    file_keepalived_sendipsecconfig_sh                       = base64gzip(file("${path.module}/files/opt/keepalived/sendipsecconfig.sh"))
    file_keepalived_createvpnaccts_sh                        = base64gzip(file("${path.module}/files/opt/keepalived/createvpnaccts.sh"))
    file_keepalived_vpn_sh                                   = base64gzip(file("${path.module}/files/opt/keepalived/vpn.sh"))
    file_rsyslog_d_00_logformat_conf                         = base64gzip(file("${path.module}/files/etc/rsyslog.d/00-logformat.conf"))
    file_rsyslog_d_25_tocloudwatch_conf                      = base64gzip(file("${path.module}/files/etc/rsyslog.d/25-tocloudwatch.conf"))
    file_rsyslog_d_24_ignore_collectd_spurious_messages_conf = base64gzip(file("${path.module}/files/etc/rsyslog.d/24-ignore-collectd-spurious-messages.conf"))
    file_rsyslog_d_24_ignore_systemd_session_slice_conf      = base64gzip(file("${path.module}/files/etc/rsyslog.d/24-ignore-systemd-session-slice.conf"))
    file_collectd_ipsec_sh                                   = base64gzip(file("${path.module}/files/var/lib/collectd/ipsec.sh"))
    file_collectd_d_exec_conf                                = base64gzip(file("${path.module}/files/etc/collectd.d/exec.conf"))
    file_collectd_d_memory_conf                              = base64gzip(file("${path.module}/files/etc/collectd.d/memory.conf"))
    file_collectd_d_network_conf                             = base64gzip(file("${path.module}/files/etc/collectd.d/network.conf"))
    file_collectd_d_table_conf                               = base64gzip(file("${path.module}/files/etc/collectd.d/table.conf"))
    file_logrotate_d_syslog                                  = base64gzip(file("${path.module}/files/etc/logrotate.d/syslog"))
    file_logrotate_d_toggle                                  = base64gzip(file("${path.module}/files/etc/logrotate.d/toggle"))
    file_sysctl_d_60_keepalived_conf                         = base64gzip(file("${path.module}/files/etc/sysctl.d/60-keepalived.conf"))
    file_sudoers_d_10_cwagent                                = base64gzip(file("${path.module}/files/etc/sudoers.d/10-cwagent"))
    file_etc_amazon-cloudwatch-agent_json                    = base64gzip(file("${path.module}/files/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"))
    tpl_sysconfig_local_config                               = base64gzip(data.template_file.sysconfig_local_config[count.index].rendered)
    tpl_sysconfig_keepalived                                 = base64gzip(data.template_file.sysconfig_keepalived[count.index].rendered)
    tpl_udev_rules_d_74_persistent_net_generator_local_rules = base64gzip(data.template_file.udev_rules_d_74_persisitent_net_generator_local_rules.rendered)
    tpl_keepalived_ipsecconfig_py                            = base64gzip(data.template_file.keepalived_ipsecconfig_py.rendered)
    tpl_keepalived_toggle_sh                                 = base64gzip(data.template_file.keepalived_toggle_sh.rendered)
    tpl_keepalived_vpncheck                                  = base64gzip(data.template_file.keepalived_vpncheck.rendered)
    tpl_collectd_d_01_conf                                   = base64gzip(data.template_file.collectd_d_01_conf[count.index].rendered)
    tpl_collectd_d_interface_conf                            = base64gzip(data.template_file.collectd_d_interface_conf.rendered)
    tpl_collectd_d_snmp_conf                                 = base64gzip(data.template_file.collectd_d_snmp_conf.rendered)
    tpl_keepalived_keepalived_conf                           = base64gzip(data.template_file.keepalived_keepalived_conf.rendered)
    tpl_snmp_snmpd_conf                                      = base64gzip(data.template_file.snmp_snmpd_conf.rendered)
  }
}

data "template_file" "sysconfig_local_config" {
  count = var.enable_awsvpn ? 2 : 0

  template = file("${path.module}/templates/etc/sysconfig/local-config.tpl")
  vars = {
    bashdebug          = var.bashdebug
    gw_eni             = aws_network_interface.awsvpn_gw_eni.id
    nat_eni            = aws_network_interface.awsvpn_nat_eni.id
    localgw            = cidrhost(local.subnet_cidr_block, 1)
    gw_localip         = aws_network_interface.awsvpn_gw_eni.private_ip
    nat_localip        = aws_network_interface.awsvpn_nat_eni.private_ip
    gw_eip             = aws_eip.awsvpn_gw_eni_eip.public_ip
    nat_eip            = aws_eip.awsvpn_nat_eni_eip.public_ip
    cidr               = local.vpc_cidr_block
    vpcnetwork         = cidrhost(local.vpc_cidr_block, 0)
    vpcnetmask         = cidrnetmask(local.vpc_cidr_block)
    vpcdnsserver       = cidrhost(local.vpc_cidr_block, 2)
    defaultdev         = var.defaultdev
    gw_enidev          = var.gw_enidev
    nat_enidev         = var.nat_enidev
    host               = "${var.environment}-awsvpn-${count.index + 1}"
    keepalivedpriority = var.keepalivedpriorities[count.index]
    aws_region         = var.aws_region
    snstopic           = aws_sns_topic.aws_vpnalarms.arn
    keepalivedrole     = var.keepalivedrole[count.index]
    ssmpath            = "/${var.company_name}/awsvpn/${local.ssm_environment}/"
  }
}

data "template_file" "udev_rules_d_74_persisitent_net_generator_local_rules" {
  template = file("${path.module}/templates/etc/udev/rules.d/74-persistent-net-generator-local.rules.tpl")
  vars = {
    gw_enidev  = var.gw_enidev
    nat_enidev = var.nat_enidev
  }
}

data "template_file" "sysconfig_keepalived" {
  count = var.enable_awsvpn ? 2 : 0

  template = file("${path.module}/templates/etc/sysconfig/keepalived.tpl")
  vars = {
    keepalivedrole = var.keepalivedrole[count.index] == "VPN-Master" ? "main" : "backup"
  }
}

data "template_file" "keepalived_ipsecconfig_py" {
  template = file("${path.module}/templates/opt/keepalived/ipsecconfig.py.tpl")
  vars = {
    region  = var.aws_region
    ssmpath = "/${var.company_name}/awsvpn/${local.ssm_environment}/"
  }
}

data "template_file" "keepalived_toggle_sh" {
  template = file("${path.module}/templates/opt/keepalived/toggle.sh.tpl")
  vars = {
    toggleport      = data.aws_ssm_parameter.toggle_port.value
    togglematch     = data.aws_ssm_parameter.toggle_match.value
    snmprocommunity = data.aws_ssm_parameter.snmp_ro_community.value
    snmprwcommunity = data.aws_ssm_parameter.snmp_rw_community.value
  }
}

data "template_file" "keepalived_vpncheck" {
  template = file("${path.module}/templates/opt/keepalived/vpncheck.tpl")
  vars = {
    snmprocommunity = data.aws_ssm_parameter.snmp_ro_community.value
  }
}

data "template_file" "collectd_d_01_conf" {
  count = var.enable_awsvpn ? 2 : 0

  template = file("${path.module}/templates/etc/collectd.d/01.conf.tpl")
  vars = {
    keepalivedrole = var.keepalivedrole[count.index]
  }
}

data "template_file" "collectd_d_interface_conf" {
  template = file("${path.module}/templates/etc/collectd.d/interface.conf.tpl")
  vars = {
    defaultdev = var.defaultdev
    gw_enidev  = var.gw_enidev
    nat_enidev = var.nat_enidev
  }
}

data "template_file" "collectd_d_snmp_conf" {
  template = file("${path.module}/templates/etc/collectd.d/snmp.conf.tpl")
  vars = {
    snmprocommunity = data.aws_ssm_parameter.snmp_ro_community.value
  }
}

data "template_file" "keepalived_keepalived_conf" {
  template = file("${path.module}/templates/etc/keepalived/keepalived.conf.tpl")
  vars = {
    defaultdev = var.defaultdev
  }
}

data "template_file" "snmp_snmpd_conf" {
  template = file("${path.module}/templates/etc/snmp/snmpd.conf.tpl")
  vars = {
    snmprocommunity = data.aws_ssm_parameter.snmp_ro_community.value
    snmprwcommunity = data.aws_ssm_parameter.snmp_rw_community.value
    ec2_region      = var.aws_region
    syscontact      = var.syscontact
  }
}

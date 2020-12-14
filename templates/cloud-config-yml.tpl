#cloud-config

write_files:
 - path: "/etc/sysconfig/local-config"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${tpl_sysconfig_local_config}
 - path: "/etc/sysconfig/keepalived"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${tpl_sysconfig_keepalived}
 - path: "/etc/sysconfig/pluto_updown"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_sysconfig_pluto_updown}
 - path: "/etc/selinux/config"
   permissions: "0400"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_selinux_config}
 - path: "/etc/udev/rules.d/74-persistent-net-generator-local.rules"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${tpl_udev_rules_d_74_persistent_net_generator_local_rules}
 - path: "/etc/systemd/system/keepalive-toggle.service"
   permissions: "0664"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_system_keepalive_toggle_service}
 - path: "/opt/keepalived/eni.sh"
   permissions: "0755"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_keepalived_eni_sh}
 - path: "/opt/keepalived/ipsecconfig.py"
   permissions: "0755"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${tpl_keepalived_ipsecconfig_py}
 - path: "/opt/keepalived/createvpnaccts.sh"
   permissions: "0755"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_keepalived_createvpnaccts_sh}
 - path: "/opt/keepalived/sendipsecconfig.sh"
   permissions: "0755"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_keepalived_sendipsecconfig_sh}
 - path: "/opt/keepalived/toggle.sh"
   permissions: "0755"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${tpl_keepalived_toggle_sh}
 - path: "/opt/keepalived/vpn.sh"
   permissions: "0755"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_keepalived_vpn_sh}
 - path: "/opt/keepalived/vpncheck"
   permissions: "0755"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${tpl_keepalived_vpncheck}
 - path: "/etc/rsyslog.d/00-logformat.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_rsyslog_d_00_logformat_conf}
 - path: "/etc/rsyslog.d/25-tocloudwatch.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_rsyslog_d_25_tocloudwatch_conf}
 - path: "/etc/rsyslog.d/24-ignore-collectd-spurious-messages.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_rsyslog_d_24_ignore_collectd_spurious_messages_conf}
 - path: "/etc/rsyslog.d/24-ignore-systemd-session-slice.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_rsyslog_d_24_ignore_systemd_session_slice_conf}
 - path: "/var/lib/collectd/ipsec.sh"
   permissions: "0755"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_collectd_ipsec_sh}
 - path: "/etc/collectd.d/01.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${tpl_collectd_d_01_conf}
 - path: "/etc/collectd.d/interface.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${tpl_collectd_d_interface_conf}
 - path: "/etc/collectd.d/exec.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_collectd_d_exec_conf}
 - path: "/etc/collectd.d/memory.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_collectd_d_memory_conf}
 - path: "/etc/collectd.d/network.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_collectd_d_network_conf}
 - path: "/etc/collectd.d/snmp.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${tpl_collectd_d_snmp_conf}
 - path: "/etc/collectd.d/table.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_collectd_d_table_conf}
 - path: "/etc/logrotate.d/toggle"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_logrotate_d_toggle}
 - path: "/etc/logrotate.d/syslog"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_logrotate_d_syslog}
 - path: "/etc/keepalived/keepalived.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${tpl_keepalived_keepalived_conf}
 - path: "/etc/sysctl.d/60-keepalived.conf"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_sysctl_d_60_keepalived_conf}
 - path: "/etc/sudoers.d/10-cwagent"
   permissions: "0440"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_sudoers_d_10_cwagent}
 - path: "/etc/snmp/snmpd.conf"
   permissions: "0600"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${tpl_snmp_snmpd_conf}
 - path: "/opt/aws/amazon-cloudwatch-agent-new/etc/amazon-cloudwatch-agent.json"
   permissions: "0644"
   owner: "root:root"
   encoding: "gzip+base64"
   content: |
     ${file_etc_amazon-cloudwatch-agent_json}


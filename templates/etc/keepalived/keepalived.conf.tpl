global_defs {
@main   router_id VPN-Master
@backup router_id VPN-Backup
}

vrrp_script vpncheck {
  script "/opt/keepalived/vpncheck"
  interval 10
  timeout 10
  fall 12
  rise 1
}

vrrp_instance VPN {
@main   state MASTER
@backup state BACKUP
  interface ${defaultdev}
  virtual_router_id 51
@main   priority 150
@backup priority 100
@main   unicast_src_ip $${MAINIP}
@backup unicast_src_ip $${BACKUPIP}
  unicast_peer {
@main   $${BACKUPIP}
@backup $${MAINIP}
  }
  notify /opt/keepalived/vpn.sh
  notify_stop "/opt/keepalived/vpn.sh VPN INSTANCE FAULT"
  track_script {
     vpncheck
  } 
}

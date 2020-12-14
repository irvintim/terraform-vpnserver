#!/bin/bash -x

source /etc/sysconfig/local-config

[ "$${debug}" -eq 1 ] && exec &> >( tee -a tmp/vpncheck.log )

STATE=$( /bin/snmpget -v2c -c "${snmprocommunity}" -OQ localhost KEEPALIVED-MIB::vrrpInstanceState.1 | \
         /bin/awk '{print $NF}'  | /bin/tr "a-z" "A-Z" )

mytag=$( /bin/basename $0 )" ($${STATE})"

[ -z "$STATE" ] && /bin/logger -t "$mytag" -i -s "Current state unknown, SNMP failure" && exit 1

if [ "$${STATE}" == "MASTER" ]; then
  if /sbin/ip link show $${gw_enidev} > /dev/null 2>&1 && \
     /sbin/ip addr show dev $${gw_enidev} | /bin/egrep -q " $${gw_localip}[ /]" && \
     /sbin/ip link show $${nat_enidev} > /dev/null 2>&1 && \
     /sbin/ip addr show dev $${nat_enidev} | /bin/egrep -q " $${nat_localip}[ /]" && \
     /sbin/pidof pluto > /dev/null 2>&1; then
    exit 0
  else
     /sbin/ip link show $${gw_enidev} > /dev/null 2>&1 || /bin/logger -t "$mytag" -i -s "$${gw_enidev} is not present"
     /sbin/ip addr show dev $${gw_enidev} | /bin/egrep -q " $${gw_localip}[ /]" || \
        /bin/logger -t "$mytag" -i -s "Interface $${gw_enidev} is not set to $${gw_localip}"
     /sbin/ip link show $${nat_enidev} > /dev/null 2>&1 || /bin/logger -t "$mytag" -i -s "$${nat_enidev} is not present"
     /sbin/ip addr show dev $${nat_enidev} | /bin/egrep -q " $${nat_localip}[ /]" || \
        /bin/logger -t "$mytag" -i -s "Interface $${nat_enidev} is not set to $${nat_localip}"
     /sbin/pidof pluto > /dev/null 2>&1 || \
        /bin/logger -t "$mytag" -i -s "IPSEC pluto process is NOT running"
     exit 1
  fi
else
   if /sbin/ip link show $${gw_enidev} > /dev/null 2>&1 || \
      /sbin/ip link show $${nat_enidev} > /dev/null 2>&1 || \
      /sbin/pidof pluto > /dev/null 2>&1; then
     /sbin/ip link show $${gw_enidev} > /dev/null 2>&1 && \
        /bin/logger -t "$mytag" -i -s "$${gw_enidev} is present, state = $${STATE}"
     /sbin/ip link show $${nat_enidev} > /dev/null 2>&1 && \
        /bin/logger -t "$mytag" -i -s "$${nat_enidev} is present, state = $${STATE}"
     /sbin/pidof pluto > /dev/null 2>&1 && \
        /bin/logger -t "$mytag" -i -s "IPSEC pluto process is running, state = $${STATE}"
     exit 1
   else
     exit 0
   fi
fi


#!/bin/bash

source /etc/sysconfig/local-config

function cleanup() {
   echo Dying
   rm -f /var/run/keepalive-toggle.pid
   exit 1
}


echo $$ > /var/run/keepalive-toggle.pid

trap cleanup INT

if [ "$${basepriority}" -gt 100 ]; then
   altprio=$(( basepriority - 100 ))
else
   altprio=$(( basepriority + 100 ))
fi

while true; do
   if ncerr=$(( echo -e "HTTP/1.1 204 No Content\r\nConnection: close\r\n\r" | \
      /bin/nc -o /var/log/toggle.log --append-output -v -w 1 -l ${toggleport} | grep -q "${togglematch}") 2>&1 ); then
     curprio=$( snmpget -v 2c -c "${snmprocommunity}" -m +KEEPALIVED-MIB:VRRP-MIB:VRRPV3-MIB localhost KEEPALIVED-MIB::vrrpInstanceBasePriority.1 | awk '{print $NF}' )
     if [ "$curprio" -eq $${altprio} ]; then newprio=$${basepriority}
     elif [ "$curprio" -eq $${basepriority} ]; then newprio=$${altprio}
     else newprio=$${basepriority}; fi
     theirip=$( echo "$ncerr" | grep "Connection from" | head -1 | sed 's/^.*Connection from \([0-9a-f\.:]*\)\.$/\1/' )
     printf "[%s] New Priority %s\n" $theirip $newprio
     snmpset -v 2c -c "${snmprwcommunity}" -m +KEEPALIVED-MIB:VRRP-MIB:VRRPV3-MIB localhost KEEPALIVED-MIB::vrrpInstanceBasePriority.1 = $${newprio} > /dev/null
   else
     theirip=$( echo "$ncerr" | grep "Connection from" | head -1 | sed 's/^.*Connection from \([0-9a-f\.:]*\)\.$/\1/' )
     echo "THEIR $theirip"
     printf "[%s] Magic code doesn't match, see /var/log/toggle.log\n" $theirip
   fi
   echo "Restart..."
done
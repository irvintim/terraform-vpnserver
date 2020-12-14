#!/bin/bash -x

source /etc/sysconfig/local-config

function cleanup()
{
   echo "SIGTERM trapped, exiting" 1>&2
   exit 1
}

trap cleanup TERM

enidev=$1
eni=$2
localip=$3
index=$4

if [ -z "$enidev" ] || [ -z "$eni" ] || [ -z "$localip" ] || [ -z "$index" ]; then
  echo "Usage: $0 <eni> <IP address> <index>" 1>&2
  exit 1
fi

if pgrep -F /var/run/eni.pid 2> /dev/null; then
   echo "$0 already running." 1>&2
   exit 1
fi
echo $$ > /var/run/eni.pid


instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | awk -F'"' '/\"region\"/ { print $4 }')
if ! ifconfig | grep ${localip} > /dev/null
then
    aId=$(aws --region ${region} ec2 describe-network-interfaces --network-interface-ids ${eni} --query 'NetworkInterfaces[].Attachment.AttachmentId' --output text)
    if [ "$aId" != "" ]; then aws --region ${region} ec2 detach-network-interface --attachment-id $aId; fi
    aws --region ${region} ec2 wait network-interface-available --network-interface-ids ${eni}
    aws --region ${region} ec2 attach-network-interface --instance-id ${instance_id} --device-index ${index} --network-interface-id ${eni}
    loops_completed=0
    loops=30
    until [ $loops_completed -eq ${loops} -o -f "/sys/class/net/${enidev}/address" ]; do
       echo "ENI $eni not available, waiting"
       : $(( loops_completed++ ))
       sleep 2
    done
    if [ $loops_completed -ge ${loops} ]; then
       echo "ENI $eni Failed to Attach, timeout"
       /bin/rm -f /var/run/eni.pid
       exit 1
    fi
    hwaddr=$(cat /sys/class/net/${enidev}/address)
    default_route=$(ip route | awk '/default/ { print $3 }')
    sed -i '/GATEWAYDEV=/d' /etc/sysconfig/network
    echo "GATEWAYDEV=${defaultdev}" >> /etc/sysconfig/network
    cat > /etc/sysconfig/network-scripts/ifcfg-${enidev} << EOL
DEVICE=${enidev}
NAME=${enidev}
HWADDR=${hwaddr}
BOOTPROTO=dhcp
ONBOOT=yes
TYPE=Ethernet
NM_CONTROLLED=no
USERCTL=yes
PEERDNS=no
IPV6INIT=yes
DHCPV6C=yes
DHCPV6C_OPTIONS=-nw
PERSISTENT_DHCLIENT=yes
DEFROUTE=no
EC2SYNC=yes
EOL

    loopcnt=0
    while ! /sbin/ip addr show dev ${enidev} | /bin/egrep -q " ${localip}[ /]" ; do
        if [ $(( loopcnt++ )) -gt 6 ]; then
           echo "DHCP failed to obtain IP address on ${enidev}" 1>&2
           exit 1
        fi
        if [ $(( loopcnt++ )) -gt 3 ]; then
           echo "DHCP failing to obtain IP address on ${enidev}, forcing network restart" 1>&2
           pkill -F /var/run/dhclient-${enidev}.pid
           /sbin/service network restart
        fi
        sleep 2
    done
    ip route | grep ${enidev} | awk -v tab="${enidev: -1}" '{printf("ip route add %s table %d\n", $0, 100 + tab)}' | bash

fi
/bin/rm -f /var/run/eni.pid
exit 0

#!/bin/bash -x

source /etc/sysconfig/local-config

[ "${debug}" -eq 1 ] && exec &> >( tee -a /tmp/vpn.log )

me=$( /bin/basename $0 )

function dying () {
   /sbin/logger -s -i -t "${me}" "Caught signal, exiting."
   cleanup
   exit 1
}

function cleanup () {
   /bin/systemctl stop ipsec.service
   /bin/pkill -F /var/run/dhclient-${gw_enidev}.pid
   /bin/pkill -F /var/run/dhclient-${nat_enidev}.pid
   /sbin/ip addr del ${extip}/32 dev lo:eip1
   /sbin/ip addr del ${natip}/32 dev lo:eip2
   for rule in $(/sbin/ip -4 rule list \
                |egrep "from .* lookup 10[12]\s" \
                |awk -F: '{print $1}'); do
     /sbin/ip -4 rule delete pref "${rule}"
   done
   /sbin/ip route flush table 101
   /sbin/ip route flush table 102
   if /sbin/ip link show ${gw_enidev} > /dev/null 2>&1; then
      aId=$(aws --region ${region} ec2 describe-network-interfaces --network-interface-ids ${gw_eni} --query 'NetworkInterfaces[].Attachment.AttachmentId' --output text)
      if [ "$aId" != "" ]; then aws --region ${region} ec2 detach-network-interface --attachment-id $aId; fi
   fi
   if /sbin/ip link show ${nat_enidev} > /dev/null 2>&1; then
      aId=$(aws --region ${region} ec2 describe-network-interfaces --network-interface-ids ${nat_eni} --query 'NetworkInterfaces[].Attachment.AttachmentId' --output text)
      if [ "$aId" != "" ]; then aws --region ${region} ec2 detach-network-interface --attachment-id $aId; fi
   fi
}

trap dying TERM

TYPE=$1
NAME=$2
STATE=$3
alertplain="$host keepalived state change: $NAME $TYPE $STATE"
alertjson="{ \\\"Message\\\": \\\"keepalived state change\\\", \
             \\\"Host\\\":    \\\"$host\\\", \
             \\\"Name\\\":    \\\"$NAME\\\", \
             \\\"Type\\\":    \\\"$TYPE\\\", \
             \\\"State\\\":   \\\"$STATE\\\" }"
/bin/aws --region $region sns publish --topic-arn ${snstopic} --message-structure json --message '{
   "default": "'"$alertplain"'",
   "email": "'"$alertplain"'",
   "email-json": "'"$alertjson"'",
   "http": "'"$alertjson"'",
   "https": "'"$alertjson"'",
   "sqs": "'"$alertjson"'" }'

case $STATE in
        "MASTER") /opt/keepalived/eni.sh ${gw_enidev} ${gw_eni} ${gw_localip} 1  | /bin/logger -s -i -t "$me"
                  if [ "${PIPESTATUS[0]}" -eq 0 ]; then
                    /sbin/ip addr add ${extip}/32 dev lo:eip1
                    /opt/keepalived/eni.sh ${nat_enidev} ${nat_eni} ${nat_localip} 2 | /bin/logger -s -i -t "$me"
                    if [ "${PIPESTATUS[0]}" -eq 0 ]; then
                      /sbin/ip addr add ${natip}/32 dev lo:eip2
                      /opt/keepalived/ipsecconfig.py
                      /opt/keepalived/createvpnaccts.sh
                      /usr/sbin/service ipsec restart
                      exit 0
                    fi
                  fi
                  /bin/logger -s -i -t "$me" "ENI ${gw_eni} setup and attachment failed"
                  exit 1
                  ;;
        "BACKUP") /bin/pkill -F /var/run/eni.pid 2> /dev/null
                  cleanup
                  exit 0
                  ;;
        "FAULT")  /bin/pkill -F /var/run/eni.pid 2> /dev/null
                  cleanup
                  exit 0
                  ;;
        *)        /bin/logger "ipsec unknown state"
                  exit 1
                  ;;
esac

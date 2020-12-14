#!/usr/bin/env bash

set -x

/usr/bin/mkdir -p /opt/keepalived

# disable selinux right now
/usr/sbin/setenforce 0
/usr/sbin/sestatus

/usr/bin/hostnamectl set-hostname ${hostname}

epel_rpm='epel-release-latest-7.noarch.rpm'
if /usr/bin/curl --connect-timeout 60 -O https://dl.fedoraproject.org/pub/epel/$${epel_rpm}; then
  /usr/bin/yum install -y $${epel_rpm}
elif /usr/bin/curl -O http://mirror.umd.edu/fedora/epel/$${epel_rpm}; then
  /usr/bin/yum install -y $${epel_rpm}
else
  echo "Unable to download $${epel_rpm}"
fi

# update yum
/usr/bin/yum update -y

# install packages to speed up setup
/usr/bin/yum install -y git \
               autofs \
               wget \
               curl \
               collectd \
               collectd-snmp \
               openssh-ldap \
               sssd \
               sssd-ldap \
               vim \
               lvm2 \
               lsof \
               nc \
               htop \
               tcpdump \
               python3-pip \
               keepalived \
               libreswan \
               nmap-ncat \
               net-snmp \
               net-snmp-utils \
               jq \
               google-authenticator

/usr/bin/systemctl enable keepalived
/usr/bin/systemctl enable keepalive-toggle
/usr/bin/systemctl enable snmpd
/usr/bin/systemctl enable collectd

# clean up
/usr/bin/yum clean all

# install modern aws package
/usr/bin/pip3 install awscli
/usr/bin/pip3 install boto3

# Install dnsmasq
/usr/bin/yum install -y dnsmasq

# Install and configure Cloudwatch Agent
/usr/bin/yum -d 0 -e 0 -y install https://s3.amazonaws.com/amazoncloudwatch-agent/centos/amd64/latest/amazon-cloudwatch-agent.rpm
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a start
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a stop
/usr/bin/mv /opt/aws/amazon-cloudwatch-agent-new/etc/amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
/usr/bin/rm -rf /opt/aws/amazon-cloudwatch-agent-new
/usr/bin/rm -rf /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/default

count=0
while [ $count -lt 120 ]; do
   MAINIP=$( /usr/local/bin/aws --region ${aws_region} ssm get-parameter --name "${ssmpath}/master_ip" | jq -r ".Parameter.Value" )
   if [ -n "$MAINIP" ]; then
     echo "MAINIP retrieved: $MAINIP, trying to ping..."
     if /usr/bin/ping -c 2 $MAINIP; then
        break
     else
        MAINIP=
     fi
   fi
   sleep 2
   : $(( count++ ))
done
if [ -z "$MAINIP" ]; then
   echo "Unable to complete provisioning SSM parameter master_ip missing" 1>&2
   exit 0
fi
count=0
while [ $count -lt 120 ]; do
   BACKUPIP=$( /usr/local/bin/aws --region ${aws_region} ssm get-parameter --name "${ssmpath}/backup_ip" | jq -r ".Parameter.Value" )
   if [ -n "$BACKUPIP" ]; then
     echo "BACKUPIP retrieved: $BACKUPIP, trying to ping..."
     if /usr/bin/ping -c 2 $BACKUPIP > /dev/null 2>&1; then
        break
     else
        BACKUPIP=
     fi
   fi
   sleep 2
   : $(( count++ ))
done
if [ -z "$BACKUPIP" ]; then
   echo "Unable to complete provisioning SSM parameter backup_ip missing" 1>&2
   exit 0
fi

/usr/bin/sed -i 's/$${MAINIP}/'$MAINIP'/' /etc/keepalived/keepalived.conf
/usr/bin/sed -i 's/$${BACKUPIP}/'$BACKUPIP'/' /etc/keepalived/keepalived.conf

MYEIP=$( curl http://169.254.169.254/latest/meta-data/public-ipv4 )
if [ -n "$${MYEIP}" ]; then
   cat > /etc/sysconfig/network-scripts/ifcfg-lo:eip0 <<EOF
DEVICE=lo:eip0
IPADDR=$${MYEIP}
NETMASK=255.255.255.255
ONBOOT=yes
NAME=lo:eip0
EOF
fi

cat > /etc/pam.d/pluto <<EOF
#%PAM-1.0

# /etc/pam.d/pluto with google authenticator

auth required pam_google_authenticator.so forward_pass

auth include system-auth use_first_pass
account required pam_nologin.so
account include system-auth
password include system-auth
session optional pam_keyinit.so force revoke
session include system-auth
session required pam_loginuid.so
EOF

aws s3 cp ${ipsec_updown_netkey} /usr/libexec/ipsec/_updown.netkey
chmod 0755 /usr/libexec/ipsec/_updown.netkey

aws s3 sync ${dnsmasq_config_path}/ /etc/dnsmasq.d/
systemctl enable dnsmasq
systemctl start dnsmasq

/opt/keepalived/ipsecconfig.py
/opt/keepalived/createvpnaccts.sh

/sbin/sysctl -p
/usr/sbin/reboot


#!/usr/bin/env bash

if [ ! -e "/etc/ipsec.d/passwd" ]; then
  echo "/etc/ipsec.d/passwd doesn't exists, aborting..." 1>&2
  exit 1
fi

for i in $( getent passwd | awk -F: '$3 >= 1001 && $3 <= 2000{print $1}' ); do
  userdel -f -r $i
done
/bin/rm -f /etc/sudoers.d/20-createvpnaccts-users

while read -r i; do
   IFS=':' read -r -a pass <<< "$i"
   if [ "${pass[3]}" == "admin" ]; then
      adduser -s /bin/bash -m "${pass[0]}"
      echo "${pass[0]} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/20-createvpnaccts-users
      if [ -n "${pass[4]}" ]; then
         mkdir /home/"${pass[0]}"/.ssh
         echo "${pass[4]}" > /home/"${pass[0]}"/.ssh/authorized_keys
         chown -R ${pass[0]}:${pass[0]} /home/"${pass[0]}"/.ssh
         chmod 700 /home/"${pass[0]}"/.ssh
         chmod 600 /home/"${pass[0]}"/.ssh/authorized_keys
      fi
   else
      adduser -s /sbin/nologin -m "${pass[0]}"
   fi
   printf "%s:%s\n" ${pass[0]} ${pass[1]} | chpasswd -e
   printf "%s\n\" RATE_LIMIT 3 30\n\" DISALLOW_REUSE\n\" TOTP_AUTH\n" "${pass[2]}" > /home/${pass[0]}/.google_authenticator
   chown ${pass[0]}:${pass[0]} /home/${pass[0]}/.google_authenticator
   chmod 600 /home/${pass[0]}/.google_authenticator
done < /etc/ipsec.d/passwd

chmod 600 /etc/sudoers.d/20-createvpnaccts-users

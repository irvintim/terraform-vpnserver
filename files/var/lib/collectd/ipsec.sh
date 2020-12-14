#!/bin/bash

HOSTNAME="${COLLECTD_HOSTNAME:-`hostname -f`}"
INTERVAL="${COLLECTD_INTERVAL:-10}"
PLUGIN=ipsec

while sleep "$INTERVAL"
do
   if ! pgrep -F /run/pluto/pluto.pid 2> /dev/null 1> /dev/null; then continue; fi
   sudo /sbin/ipsec whack --globalstatus | \
        /bin/sed 's/\./=/' | \
        /bin/awk -F= -v i=${INTERVAL} -v h=${HOSTNAME} -v p=${PLUGIN} \
                '$1 == "current"{printf("PUTVAL %s/%s-%s.%s/gauge-%s interval=%s N:%s\n",    h, p, p, $1, $2, i, $3)}
                 $1 == "total"{  printf("PUTVAL %s/%s-%s.%s/gauge-%s interval=%s N:%s\n",    h, p, p, $1, $2, i, $3)}
                 $1 == "config"{ printf("PUTVAL %s/%s-%s.%s/gauge-%s interval=%s N:%s\n",    h, p, p, $1, $2, i, $3)}'

   sudo /sbin/ipsec whack --clearstats
done


#!/bin/bash

source /etc/sysconfig/local-config

path=$1
if [ ! -e "$path" ]; then
  echo "Usage: $0 <filepath>"
fi

file=$(basename $path)

aws --region ${region} ssm put-parameter --overwrite --name ${ssmpath}ipsec.d/${file} --value "$( cat ${path} )"
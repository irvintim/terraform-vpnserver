#!/usr/bin/env python3

import os
import boto3
import botocore.exceptions

region = "${region}"
ssmpath = "${ssmpath}"


ssm = boto3.client("ssm", region_name=region)

try:
    config = ssm.get_parameters_by_path(
        Path=ssmpath + "ipsec.d/", Recursive=True, WithDecryption=True
    )
except (
    SSM.Client.exceptions.InternalServerError,
    SSM.Client.exceptions.InvalidFilterKey,
    SSM.Client.exceptions.InvalidFilterOption,
    SSM.Client.exceptions.InvalidFilterValue,
    SSM.Client.exceptions.InvalidKeyId,
    SSM.Client.exceptions.InvalidNextToken,
):
    config = {}
    print("SSM Error, aborting")
    exit(1)

try:
    l = open("/etc/ipsec.d/ssm-managed", "r")
except IOError:
    pass
else:
    for managed in l:
        try:
            os.remove(managed.rstrip())
        except OSError as err:
            print(err)
            pass
    l.close()

l = open("/etc/ipsec.d/ssm-managed", "w")
for parameter in config["Parameters"]:
    file = "/etc/" + "/".join(parameter["Name"].split("/")[-2:])
    f = open(file, "w")
    f.write(parameter["Value"])
    f.write("\n")
    f.close()
    os.chmod(file, 0o600)
    l.write(file)
    l.write("\n")

l.close()

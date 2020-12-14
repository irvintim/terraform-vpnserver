com2sec pubUser  default       ${snmprocommunity}
com2sec privUser default       ${snmprwcommunity}
group   pubGroup v1            pubUser
group   pubGroup v2c           pubUser
group   privGroup v1           privUser
group   privGroup v2c          privUser
view    systemview    included   .1.3.6.1.2.1.1
view    systemview    included   .1.3.6.1.2.1.25.1.1
view    systemview    included   .1.3.6.1.4.1.9586.100
view    keepalive     included   .1.3.6.1.4.1.9586.100
access  pubGroup ""      any       noauth    exact  systemview none none
access  privGroup ""     any       noauth    exact  systemview keepalive none
syslocation AWS EC2 ${ec2_region}
syscontact ${syscontact}
dontLogTCPWrappersConnects yes
master agentx

## What to find in this repo

A docker file for telegraf that includes the following MIB: 
- Junos 17.4R2.4 downloaded from https://apps.juniper.net/mib-explorer/download.jsp#product=Junos%20OS 

## How to test it

Download the image
```
$ docker pull ksator/telegraf_snmp
```
Verify
```
$ docker images ksator/telegraf_snmp
REPOSITORY             TAG                 IMAGE ID            CREATED             SIZE
ksator/telegraf_snmp   latest              1e25f6aad4e5        23 minutes ago      315MB
```
The MIB are in the directory `/usr/share/snmp/mibs`. Run this command to verify: 
```
$ docker run -i -t ksator/telegraf_snmp ls /usr/share/snmp/mibs
```
Run this command to test it (community `public`, snmp version `2c`, ip `100.123.1.0`, mib `JUNIPER-MIB`, object name `jnxBoxDescr.0`)
```
$ docker run -i -t ksator/telegraf_snmp snmpget -v 2c -c public 100.123.1.0 JUNIPER-MIB::jnxBoxDescr.0
```
Here's an output example: `Juniper VMX Internet Backbone Router`

This is the equivalent command of
```
$ docker run -i -t ksator/telegraf_snmp snmpget -v 2c -c public 100.123.1.0 1.3.6.1.4.1.2636.3.1.2.0
```

## How to use it



## What to find in this repo

A docker file for telegraf that includes the following MIB: 
- Junos 17.4R2.4 downloaded from https://apps.juniper.net/mib-explorer/download.jsp#product=Junos%20OS 

## requirements to use this repo

install docker


## How to test this repo

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

## How to use this repo

### Influxdb

pull influxdb docker image 
```
$ docker pull influxdb
```
Verify
```
$ docker images influxdb
```
Instanciate an influxdb container
```
$ docker run -d --name influxdb -p 8083:8083 -p 8086:8086 --network=test influxdb 
```
Verify
```
$ docker ps | grep influxdb
```
### Telegraf

pull ksator/telegraf_snmp docker image 
```
$ docker pull ksator/telegraf_snmp
```
Verify
```
$ docker images ksator/telegraf_snmp
```
create a telegraf configuration file 

```
$ cat telegraf.conf
[[inputs.snmp]]
   # List of agents to poll
   agents = ["100.123.1.0:161", "100.123.1.1:161", "100.123.1.2:161"]

   # Polling interval
   interval = "5s"

   # Timeout for each SNMP query.
   timeout = "10s"

   # Number of retries to attempt within timeout.
   retries = 3

   # SNMP version
   version = 2

   # SNMP community string.
   community = "public"

   # Measurement name
   name = "demo"

    [[inputs.snmp.field]]
    name = "hostname"
    oid = ".1.3.6.1.2.1.1.5.0"
    is_tag = true

    #  Juniper Networks MIB

    [[inputs.snmp.field]]
    name = "jnxBoxSerialNo"
    oid="JUNIPER-MIB::jnxBoxSerialNo.0"

    [[inputs.snmp.field]]
    name = "jnxBoxDescr"
    oid="JUNIPER-MIB::jnxBoxDescr.0"

    [[inputs.snmp.field]]
    name = "jnxBoxInstalled"
    oid="JUNIPER-MIB::jnxBoxInstalled.0"

[[outputs.influxdb]]

  urls = ["http://influxdb:8086"]
  database = "mydb"
  timeout = "5s"
  username = "telegraf"
  password = "password123"

```
instanciate a telegraf container
```
$ docker run -d --name telegraf \
-v $PWD/telegraf.conf:/etc/telegraf/telegraf.conf \
--network=test \
 ksator/telegraf_snmp 
```
verify
```
$ docker ps | grep telegraf_snmp
```

start a shell session in the influxdb container and query the influxdb database to verify

```
$ docker exec -it influxdb bash
root@7d6138d695d4:/# influx
Connected to http://localhost:8086 version 1.7.2
InfluxDB shell version: 1.7.2
Enter an InfluxQL query
```
list databases
```
> show databases
name: databases
name
----
_internal
mydb
```
list measurements
```
> use mydb
Using database mydb
> show measurements
name: measurements
name
----
demo
```
query
```
> select * from "demo" order by desc limit 6
name: demo
time                agent_host  host         hostname   jnxBoxDescr                          jnxBoxInstalled jnxBoxSerialNo
----                ----------  ----         --------   -----------                          --------------- --------------
1547163595000000000 100.123.1.2 458327811d17 vMX-addr-2 Juniper VMX Internet Backbone Router 22252400        VM5B6A238173
1547163595000000000 100.123.1.1 458327811d17 vMX-addr-1 Juniper VMX Internet Backbone Router 22254100        VM5B6A238173
1547163595000000000 100.123.1.0 458327811d17 vMX-addr-0 Juniper VMX Internet Backbone Router 22259900        VM5B6A238173
1547163590000000000 100.123.1.2 458327811d17 vMX-addr-2 Juniper VMX Internet Backbone Router 22251900        VM5B6A238173
1547163590000000000 100.123.1.1 458327811d17 vMX-addr-1 Juniper VMX Internet Backbone Router 22253600        VM5B6A238173
1547163590000000000 100.123.1.0 458327811d17 vMX-addr-0 Juniper VMX Internet Backbone Router 22259400        VM5B6A238173
```
exit influxdb container
```
> exit
root@7d6138d695d4:/# exit
exit
```
Stop and remove the containers
```
$ docker stop telegraf influxdb
```
```
$ docker rm telegraf influxdb
```

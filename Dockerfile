FROM telegraf:1.9.1

MAINTAINER Khelil Sator <ksator@juniper.net>

RUN rm /etc/apt/sources.list && \
echo "deb http://deb.debian.org/debian stretch main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://security.debian.org/debian-security stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://deb.debian.org/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y unzip snmp-mibs-downloader 

RUN wget https://www.juniper.net/documentation/software/junos/junos174/juniper-mibs-17.4R2.4.zip -O juniper-mibs-17.4R2.4.zip && \
unzip juniper-mibs-17.4R2.4.zip 

RUN mv JuniperMibs/* /usr/share/snmp/mibs/

RUN download-mibs

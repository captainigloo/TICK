FROM arm32v7/ubuntu:20.04 as build
#ARG DEBIAN_FRONTED=noninteractive
# Install APT packages
#RUN apt-get update && apt-get install -y wget curl telnet supervisor net-tools
RUN apt-get -y --force-yes install cron telnet vim git nano make gcc g++ apt-transport-https sudo logrotate
RUN apt-get -y --force-yes install procps uptimed gnupg2 apt-utils sysvinit-core systemd
#-sysv
RUN apt-get -y --force-yes install lsb-release initscripts libsystemd0 libudev1 sysvinit-utils udev util-linux rsyslog 

# Download & Install Debian packages

#Telegraf
RUN wget https://dl.influxdata.com/telegraf/releases/telegraf_1.5.0-1_amd64.deb \
  && dpkg -i telegraf_1.5.0-1_amd64.deb

# InfluxDB
RUN wget https://dl.influxdata.com/influxdb/releases/influxdb_1.4.2_amd64.deb \
  && dpkg -i influxdb_1.4.2_amd64.deb

# Chronograf
RUN wget https://dl.influxdata.com/chronograf/releases/chronograf_1.4.0.1_amd64.deb \
  && dpkg -i chronograf_1.4.0.1_amd64.deb

# Kapacitor
RUN wget https://dl.influxdata.com/kapacitor/releases/kapacitor_1.4.0_amd64.deb \
  && dpkg -i kapacitor_1.4.0_amd64.deb

RUN influxd config > /etc/influxdb/influxdb.generated.conf

# Configure supervisord
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD ./influxdb.conf /etc/influxdb/influxdb.conf
ADD ./telegraf.conf /opt/telegraf/telegraf.conf
ADD ./chronograf.toml /opt/chronograf/config.toml
RUN mkdir /opt/kapacitor/
ADD ./kapacitor.conf /opt/kapacitor/kapacitor.conf
RUN rm *.deb
RUN mkdir -p /data/chronograf && chown -R chronograf:chronograf /data/chronograf && chmod 777 /data/chronograf

VOLUME /data/influx/data
VOLUME /data/influx/meta
VOLUME /data/influx/wal
VOLUME /data/kapacitor
VOLUME /data/chronograf

EXPOSE  80
EXPOSE 8125/udp
EXPOSE 10000
EXPOSE 8083
EXPOSE 8086
EXPOSE 8088
CMD     ["/usr/bin/supervisord"]

#!/bin/sh

# https://blog.ja-ke.tech/2019/02/24/openwrt-collectd-influx.html

####################################

# One time setup:
# Activate collectd emulation on influxdb

# Copy  /usr/share/collectd/types.db
#   from openwrt box to influx host at same path

# Note, have to add firewall rule if traversing subnets
# And collectd emulation listens on 192.168.12.29:25826 (UDP) 

# Note, C7 doesn't seem to give thermal output

###############################
# On the OpenWRT boxes,

opkg update
opkg install \
  collectd \
  collectd-mod-cpu \
  collectd-mod-interface \
  collectd-mod-iwinfo \
  collectd-mod-load \
  collectd-mod-memory \
  collectd-mod-netlink \
  collectd-mod-network \
  collectd-mod-uptime \
  collectd-mod-thermal
rm /etc/config/collectd-opkg

# Configure /etc/collectd.conf
# TODO: Put this in VCS

mkdir -p /etc/collectd/conf.d

echo '
BaseDir "/var/run/collectd"
Include "/etc/collectd/conf.d"
PIDFile "/var/run/collectd.pid"
PluginDir "/usr/lib/collectd"
TypesDB "/usr/share/collectd/types.db"
Interval    10
ReadThreads 2

# Output plugin, to send to remote collectd (influxdb)
LoadPlugin network
<Plugin "network">
  Server "192.168.12.29"
</Plugin>

# Input plugins
LoadPlugin cpu
LoadPlugin interface
LoadPlugin iwinfo
LoadPlugin load
LoadPlugin netlink
LoadPlugin memory
LoadPlugin uptime
LoadPlugin thermal
' > /etc/collectd.conf

# Test run
# /usr/sbin/collectd -C /tmp/collectd.conf -f


# Enable and start collectd
/etc/init.d/collectd enable
/etc/init.d/collectd start

# Verify running
ps $(pgrep collectd)

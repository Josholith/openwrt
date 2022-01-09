#!/bin/sh

# List out MAC addresses of associated clients
IFACES=$(iwinfo | grep ESSID | awk '{print $1}' | sort)
for IFACE in $IFACES
do
  AP=$(iwinfo $IFACE info | grep 'Access Point' | egrep -io '([0-9A-F]{2}[:-]){5}([0-9A-F]{2})')
  SSID=$(iwinfo $IFACE info |  grep 'ESSID:' | awk '{$1=$2=""; print $0}' | sed 's/"//g' | sed 's/^ *//')
  CHANNEL=$(iwinfo $IFACE info | egrep -o 'Channel: [0-9]+' | awk '{print $NF}')
  STATIONS=`iwinfo $IFACE assoclist | egrep -io '^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})' | sort`
  for STATION in $STATIONS ; do
     echo "${HOSTNAME} ${AP} ${STATION} ${CHANNEL} ${SSID}"
  done
done

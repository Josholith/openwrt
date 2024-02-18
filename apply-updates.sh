#!/bin/ash

echo ; date ; echo Updating package list:
opkg update

echo ; date ; echo Checking for upgradable packages:
if ! opkg list-upgradable | grep -q . ; then
  echo Nothing to upgrade
  exit 0
fi

echo ; date ; echo Available updates:
P=$(opkg list-upgradable)
echo "$P"

echo ; date ; echo Applying updates:
echo "$P"
echo "$P" | awk '{print $1}' | xargs opkg install

echo ; date ; echo  Rebooting
reboot


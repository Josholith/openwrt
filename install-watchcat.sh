# Install packages
opkg update
opkg install watchcat

# Configure watchcat
echo "config watchcat
  # If unable to reach (ping) the rest of the network for 1 hour,
  # do a soft reboot. If soft reboot doesn't work in 1 min, then
  # request a hard reboot.
  option period '1h'
  option mode 'ping_reboot'
  option pinghosts '192.168.212.1'
  option forcedelay '1m'" > /etc/config/watchcat

# Start watchcat now.
# It is enabled on boot automatically at installation time.
/etc/init.d/watchcat start


# Install packages
opkg update
opkg install iperf3

# Create /etc/init.d/iperf3 ...
echo '#!/bin/sh /etc/rc.common

START=98

start () {
  service_start /usr/bin/sudo -u nobody /usr/bin/iperf3 -s -D
}

stop() {
  /usr/bin/sudo -u nobody /usr/bin/killall -q iperf3
}
' > /etc/init.d/iperf3

# Enable & start the service
chmod +x /etc/init.d/iperf3
/etc/init.d/iperf3 enable
/etc/init.d/iperf3 start

# Optionally you could reboot to be positive
# iperf3 will automatically come up.  I usally
# skip this.

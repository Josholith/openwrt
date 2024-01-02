#!/bin/sh

## List out MAC addresses of associated clients

echo "Content-Type: application/json"
echo

echo "{"
echo "  \"hostname\": \"$HOSTNAME\","
echo "  \"interfaces\": {"

IFACES=$(iwinfo | grep ESSID | awk '{print $1}' | grep -v mesh | sort)

for IFACE in $IFACES
do
  INFO=$(iwinfo $IFACE info)
  CHANNEL=$(echo "$INFO" | egrep -o 'Channel: [0-9]+' | awk '{print $NF}')
  if [ -z "$CHANNEL" ] ; then continue ; fi

  echo -ne $ISEP
  ISEP=",\n"
  echo "    \"$IFACE\": {"
  SSID=$(echo "$INFO" |  grep -m1 'ESSID:' | awk '{$1=$2=""; print $0}' | sed 's/"//g' | sed 's/^ *//')
  AP=$(echo "$INFO" | grep -m1 'Access Point' | egrep -io '([0-9A-F]{2}[:-]){5}([0-9A-F]{2})')
  HT_MODE=$(echo "$INFO" | egrep -o 'HT Mode: .+'     | awk '{print $NF}')
  echo "      \"ap\": \"$AP\","
  echo "      \"ssid\": \"$SSID\","
  echo "      \"channel\": \"$CHANNEL\","
  echo "      \"htMode\": \"$HT_MODE\","
  echo -n "      \"stations\": {"


  ALIST=$(iwinfo $IFACE assoclist)
  STATIONS=$(echo "$ALIST" | egrep -io '^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})' | sort)

  SSEP="\n"
  HAS_STATIONS=""
  for STATION in $STATIONS ; do
    HAS_STATIONS=1
    RXPACKETS=$(echo "$ALIST" | grep -m1 -A1 $STATION | grep -m1 RX: | awk '{print $(NF-1)}')
    TXPACKETS=$(echo "$ALIST" | grep -m1 -A2 $STATION | grep -m1 TX: | awk '{print $(NF-1)}')
    RXBITRATE=$(echo "$ALIST" | grep -m1 -A1 $STATION | grep -m1 RX: | awk '{print $2 * 10^6}')
    TXBITRATE=$(echo "$ALIST" | grep -m1 -A2 $STATION | grep -m1 TX: | awk '{print $2 * 10^6}')
    SIGNAL=$(   echo "$ALIST" | grep -m1     $STATION | grep -m1 -Eo '\-[0-9]+ dBm /' | awk '{print $1}')
    echo -ne $SSEP
    SSEP=",\n"
    echo "        \"$STATION\": {"
    echo "          \"rxPackets\": $RXPACKETS,"
    echo "          \"txPackets\": $TXPACKETS,"
    echo "          \"rxBitrate\": $RXBITRATE,"
    echo "          \"txBitrate\": $TXBITRATE,"
    echo "          \"signal\"   : $SIGNAL"
    echo -n "        }"
  done
  if [ -n "$HAS_STATIONS" ] ; then
    echo ; echo "      }"
  else
    echo "}"
  fi
  echo -n "    }"
done
echo

echo '  }'
echo '}'


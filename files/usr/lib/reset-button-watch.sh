#!/bin/sh
#
# Basic reset button handler for VP-series hardware.
# Reboots and resets config if button is pressed.
#

PORT=0xa00      # I/O port address
MASK=0x04       # Bit 2 = 0 means pressed, 1 means not pressed
INTERVAL=1      # polling interval (seconds)

while :; do
    byte=$(dd if=/dev/port bs=1 skip=$((PORT)) count=1 2>/dev/null \
           | hexdump -v -e '1/1 "%u"')

    [ -z "$byte" ] && { echo "read error"; exit 1; }

    if [ $((byte & MASK)) -eq 0 ]; then
        # Button is pressed - performing factory reset
        firstboot -y
        reboot
        exit 0
    fi

    sleep "$INTERVAL"
done

#!/bin/sh
#
# Basic reset button handler for VP-series hardware.
# Reboots and resets config if button is pressed.
#

PORT=0xa00      # I/O port address
MASK=0x04       # Bit 2 = 0 means pressed, 1 means not pressed
INTERVAL=1      # polling interval (seconds)
LOGTAG="reset-button-watch"

logger -t "$LOGTAG" "started"

COUNTER=0

while :; do
    byte=$(dd if=/dev/port bs=1 skip=$((PORT)) count=1 2>/dev/null \
           | hexdump -v -e '1/1 "%u"')

    [ -z "$byte" ] && { logger -t "$LOGTAG" "read error - exiting"; exit 1; }

    if [ $((byte & MASK)) -eq 0 ]; then
        # Button is pressed - increment counter
        COUNTER=$((COUNTER + 1))
        
        if [ "$COUNTER" -eq 10 ]; then
            # Button has been pressed for 10s in a row, perform factory reset
            logger -t "$LOGTAG" "button held 10 s - factory reset initiated"
            firstboot -y
            reboot
            exit 0
        fi
    else
        COUNTER=0
    fi

    sleep "$INTERVAL"
done

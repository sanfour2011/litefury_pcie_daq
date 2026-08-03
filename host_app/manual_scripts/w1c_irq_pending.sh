#!/usr/bin/env bash

# Ziel-Register und Wert
RESOURCE="/sys/bus/pci/devices/0000:01:00.0/resource2"
ADDRESS="0x4"
TYPE="w"
VALUE="0x04"


# Befehl ausführen
if sudo pcimem "$RESOURCE" "$ADDRESS" "$TYPE" "$VALUE" w 0x04; then
    echo -e "\n[OK]"
else
    echo -e "\n[FEHLER]" >&2
    exit 1
fi

#!/usr/bin/env bash

# Ziel-Register und Wert
RESOURCE="/sys/bus/pci/devices/0000:01:00.0/resource2"
ADDRESS="0x0"
TYPE="w"
VALUE="0x1"



# Befehl ausführen
if sudo pcimem "$RESOURCE" "$ADDRESS" "$TYPE" "$VALUE"; then
    echo -e "\n[OK]"
else
    echo -e "\n[FEHLER]" >&2
    exit 1
fi

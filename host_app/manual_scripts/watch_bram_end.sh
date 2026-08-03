#!/usr/bin/env bash
#!!!!!!!!!!!!!ONLY BYTE ADRESSES!!!!!!in 4er schritte!!
# Ziel-Register und Wert
RESOURCE="/sys/bus/pci/devices/0000:01:00.0/resource2"
ADDRESS="0x3FDC"
TYPE="w*10" #slv0, slv1, slv2 (slv2 ist nicht nötig aber um sicher zustellen das nix reingeschreiben wird!)
VALUE=""
INTERVAL="0.2"

# sudo pcimem /sys/bus/pci/devices/0000\:01\:00.0/resource2 0x3FF0 w*10

# Befehl ausführen
if sudo watch -n $INTERVAL pcimem "$RESOURCE" "$ADDRESS" "$TYPE" "$VALUE"; then
    echo -e "\n[OK] Akquisition erfolgreich gestartet!"
else
    echo -e "\n[FEHLER] Fehler beim Schreiben in den Speicherbereich." >&2
    exit 1
fi

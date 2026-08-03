#!/bin/bash

echo 1 | sudo tee /sys/bus/pci/devices/0000:01:00.0/remove

lspci -s 0000:01:00.0

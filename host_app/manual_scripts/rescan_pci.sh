#!/bin/bash

echo 1 | sudo tee /sys/bus/pci/rescan

lspci -s 0000:01:00.0



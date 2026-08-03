#!/bin/bash

echo 1 | sudo tee /sys/bus/pci/devices/0000:01:00.0/reset

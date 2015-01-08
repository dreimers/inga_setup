# inga initial setup

These scripts can help to prepare brand-new INGA nodes for productive use.

## Generating an Printing labels
./print_label $labelfile

## Get ftdi serial from serial device node (e.g. /dev/ttyUSBn)
./get_ftdi_serial $deviceNode

## Flash bootloader on node with given serial device node (e.g. /dev/ttyUSBn)
./flash_bootloader $deviceNode

## Look for working bootloader on node with given serial device node (e.g. /dev/ttyUSBn)
./check_bootloader $deviceNode

## Run complete automatic initial setup on all connected nodes
./run_initial_setup.sh

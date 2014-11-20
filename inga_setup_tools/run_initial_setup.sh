#!/bin/bash

source utils.sh

cleanup(){
  ln -fs "$(basename $LOGFILE)" logs/lastlog
}

trap cleanup EXIT

SERIAL=$1
JOBNAME="node-"$SERIAL
LOGFILE="logs/initial_setup-$(timestamp).log"
INGA_DEVICE_PATH="/dev/inga"
DEVICES=()

export LOGFILE


print_info "Logging to $LOGFILE"
# print_info redirects output to file if and only if $LOGFILE exists so create it here
touch $LOGFILE
print_info "### Running initial setup ###"
print_info "Searching for nodes..."

if [ -a $INGA_DEVICE_PATH ];
then
  for DEVICE in $(find $INGA_DEVICE_PATH -name "node-*")
  do
    print_info "found node at $DEVICE"
    DEVICES+=("$DEVICE")
  done

  NUMBER_OF_DEVICES_FOUND="${#DEVICES[@]}"
else
  print_info "Path $INGA_DEVICE_PATH does not exist. Possible reasons:"
  print_info "no device connected, udev-rule not working"
  print_info "or device(s) are missing FTDI EEPROM configuration"
  NUMBER_OF_DEVICES_FOUND=0
fi

print_info "$NUMBER_OF_DEVICES_FOUND nodes found"

if [ $NUMBER_OF_DEVICES_FOUND -eq "0" ];
then
  print_info "No devices found aborting"
  exit
fi

print_info "Flashing bootloader through FTDI Bitbang..."

for DEVICE in ${DEVICES[@]};
do
  print_info "Trying node $DEVICE"
  ./flash_bootloader $DEVICE
done



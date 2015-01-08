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
NODES=()

# Attempts to flash to bootloader
MAX_BOOTLOADER_ATTEMPS=3
export LOGFILE


print_info "Logging to $LOGFILE"
# print_info redirects output to file if and only if $LOGFILE exists so create it here
touch $LOGFILE
print_info "### Running initial setup ###"
print_info "# Step 1 - Searching for nodes..."

if [ -a $INGA_DEVICE_PATH ];
then
  for NODE in $(find $INGA_DEVICE_PATH -name "node-*")
  do
    print_info "found node at $NODE"
    NODES+=("$NODE")
  done

  NUMBER_OF_NODES_FOUND="${#NODES[@]}"
else
  print_info "Path $INGA_DEVICE_PATH does not exist. Possible reasons:"
  print_info "no node connected, udev-rule not working"
  print_info "or node(s) are missing FTDI EEPROM configuration"
  NUMBER_OF_NODES_FOUND=0
fi

print_info "$NUMBER_OF_NODES_FOUND nodes found"

if [ $NUMBER_OF_NODES_FOUND -eq "0" ];
then
  print_info "No nodes found aborting"
  exit
fi

print_info "# Step 2 - Preparing nodes with bootloader"

# node counter
let DEV_NO=1

for NODE in ${NODES[@]};
do
  print_info "Trying node $NODE ($((DEV_NO++))/$NUMBER_OF_NODES_FOUND):"

  for TRYNR in `seq 1 $MAX_BOOTLOADER_ATTEMPS`;
  do
    ./check_bootloader $NODE
    NOT_HAS_BOOTLOADER=$?

    if [ $NOT_HAS_BOOTLOADER -eq 0 ]; then
      print_info "Found bootloader on $NODE"". Excellent."
      NODES_W_BOOTLOADER+=("$NODE")
      break
    else
      print_info "Bootloader is missing"
      print_info "Flashing bootloader through FTDI Bitbang... TryNo ($TRYNR/$MAX_BOOTLOADER_ATTEMPS)"
      ./flash_bootloader $NODE
      # TODO workaround for missing devices after runnnig avrdude
      sudo modprobe -r ftdi_sio && sudo modprobe ftdi_sio
      #
      if [ $TRYNR -eq $MAX_BOOTLOADER_ATTEMPS ];
      then
        print_info "Node $NODE is still missing bootloader. Skipping node for now."
      fi
    fi
  done
done


for NODE in ${NODES_W_BOOTLOADER[@]};
do
  print_info "Trying node $NODE"
done



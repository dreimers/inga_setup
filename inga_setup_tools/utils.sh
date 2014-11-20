#!/bin/bash

print_info(){
  if [ -f $LOGFILE ]; then
    echo "["$0"] $1" 2>&1 | tee -a $LOGFILE
  else
    echo "["$0"]" $1
  fi
}

timestamp() {
  echo $(date +"%s")
}


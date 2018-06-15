#!/bin/bash

FW=./nodemcu-master-22-modules-2018-05-27-13-21-02-float.bin
PORT=/dev/ttyUSB0 

if [ -z $FW ]; then
    echo "FW file is empty"
    exit
fi

sudo esptool.py --port $PORT write_flash -fm qio 0x00000 $FW

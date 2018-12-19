#!/bin/bash

DEFPORT=/dev/ttyUSB0
BAUD=250000
ESPTOOL=esptool.py

PORT=${1:-$DEFPORT}
FW=$2

FILE=$(cd `dirname $0` && pwd)/$FW

if [ $# -lt 1 ]; then
    echo "Usage:"
    echo "  flash.sh <serial-port> <binary-file>"
    echo "  Example: $0 /dev/ttyUSB0 ./fw.bin"
    exit
fi

if [ ! -f $FILE ]; then
    echo "Firmware file $FILE not found"
    exit
fi

$ESPTOOL --port $PORT --baud $BAUD write_flash -fm qio 0x00000 $FILE

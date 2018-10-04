#!/bin/bash

LUATOOL=luatool.py
ESPTOOL=esptool.py
DEFPORT=/dev/ttyUSB0
DEFMODE=noflash
PORT=${1:-$DEFPORT}
MODE=${2:-$DEFMODE}
BAUD=115200
FW=nodemcu-master-24-modules-2018-09-20-13-22-49-float.bin
FILE=$(cd `dirname $0` && pwd)/$FW

if [[ $MODE != "noflash" ]]; then
    MODE=$DEFMODE
fi

echo "Board will be erased and all data will be lost!"	

if [[ $MODE = "reflash" ]]; then
    read -p "Hold button on the board and reboot it. Then press ENTER to continue..."
    
    #Flash chip
    echo "Programming..."
    $ESPTOOL --port $PORT write_flash -fm qio 0x00000 $FILE
    if [[ $? != 0 ]]; then 
        exit 
    fi

    sleep 5
else
    echo "FW flash skipped.."    
fi


#Clear files on flash memory
echo "Clearing..."
$LUATOOL -p $PORT -b $BAUD --wipe
echo

sleep 3

#Do upload
for fname in ./*.lua; do
	echo "Uploading: $fname..."
	$LUATOOL -p $PORT -b $BAUD -f ./$fname --bar
done

#Verify uploaded file list
list=$($LUATOOL -p $PORT -b $BAUD --list | awk -F '[:,]' '/^name/{print $2}')

if [[ $(echo ${files[@]} ${list[@]} | tr ' ' '\n' | sort | uniq -d | wc -l) == ${#files[@]} ]]; then
	echo "---------------"
	echo -e "Uploaded ${#files[@]} files.\nDone"
else
	echo "Upload error!"
	exit
fi


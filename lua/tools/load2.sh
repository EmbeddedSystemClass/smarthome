#!/bin/sh
delay=0.5
file=`basename $1`
(k=1;echo "file.remove(\"$file\")";sleep $delay;echo "file.open(\"$file\",\"w\")";sleep $delay; while read line;do echo "print($k);file.writeline([[$line]])"; k=$((k+1)); sleep $delay; done < $1;echo "file.close()")|ncat -v $2 2323

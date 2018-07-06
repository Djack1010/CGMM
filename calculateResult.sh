#!/bin/bash
#Created by Giacomo Iadarola
#v1.0 - 22/05/18

SCRIPTPATH=$PWD
TESTNUM=$1
mkdir -p $SCRIPTPATH/RESULTS

if [ ! -f $SCRIPTPATH/Test_sup.log ]; then
    echo "Test_sup.log file not found, exiting..."
    exit
else
    mv $SCRIPTPATH/Test_sup.log $SCRIPTPATH/RESULTS/Test_sup_$TESTNUM.log
fi

T=0
ST=0
V=0
SV=0
N=0
while read l; do
    if [ "$(echo $l | grep "RES->")" ]; then
        CLEANLINE=$(echo ${l/e/*10^})
        T=$(bc <<< "scale = 6; ${T} + $(echo $l | cut -d':' -f4 | cut -d'+' -f1) ")        
        ST=$(bc <<< "scale = 6; ${ST} + $(echo $l | cut -d':' -f4 | cut -d'+' -f2 | cut -d' ' -f1 | sed -e 's/e/\*10\^/g') ")        
        V=$(bc <<< "scale = 6; ${V} + $(echo $l | cut -d':' -f5 | cut -d'+' -f1) ")        
        SV=$(bc <<< "scale = 6; ${SV} + $(echo $l | cut -d':' -f5 | cut -d'+' -f2 | sed -e 's/e/\*10\^/g')  ") 
        N=$(($N+1))
    fi    
done < $SCRIPTPATH/RESULTS/Test_sup_$TESTNUM.log
T=$(bc <<< "scale = 4; ${T} / ${N} ")        
ST=$(bc <<< "scale = 2; ${ST} / ${N} ")        
V=$(bc <<< "scale = 4; ${V} / ${N} ")        
SV=$(bc <<< "scale = 2; ${SV} / ${N} ") 
echo "FINAL RESULT-> T:$T+$ST V:$V+$SV" >> $SCRIPTPATH/RESULTS/Test_sup_$TESTNUM.log
date >> $SCRIPTPATH/RESULTS/Test_sup_$TESTNUM.log
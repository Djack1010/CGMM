#!/bin/bash
#Created by Giacomo Iadarola
#v1.0 - 22/05/18

SCRIPTPATH=$PWD
TESTNUM=$1
mkdir -p $SCRIPTPATH/RESULTS/res_$TESTNUM

if [ ! -f $SCRIPTPATH/Test_sup$TESTNUM.log ]; then
    echo "Test_sup.log file not found, exiting..."
    exit
else
    mv $SCRIPTPATH/Test_sup$TESTNUM.log $SCRIPTPATH/RESULTS/res_$TESTNUM
fi

T=0
ST=0
V=0
SV=0
N=0
while read l; do
    if [ "$(echo $l | grep "RES->")" ]; then
        T=$(bc <<< "scale = 6; ${T} + $(echo $l | cut -d':' -f4 | cut -d'+' -f1) ")        N=$(($N+1))
    fi    
done < $SCRIPTPATH/RESULTS/res_$TESTNUM/Test_sup$TESTNUM.log
echo $(bc <<< "scale = 2; $T / $N ") >>
#PER=$(bc <<< "scale = 2; ($PAR / $TOT) * 100")
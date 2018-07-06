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

rm -f $SCRIPTPATH/RESULTS/temp.log

Bsvm=0
Bgamma=0
BV=0
BSV=0

BsvmE=0
BgammaE=0
BVE=0
BSVE=0
SVMCS=("100" "50" "25" "10" "5" "2" "1")
GAMMAS=("50" "25" "10" "5" "2" "1")
for svm in "${SVMCS[@]}"; do
    for gamma in "${GAMMAS[@]}"; do
        T=0
        ST=0
        V=0
        SV=0
        N=0
        cat $SCRIPTPATH/RESULTS/Test_sup_$TESTNUM.log | grep "RES_${svm}_${gamma}->" >> $SCRIPTPATH/RESULTS/temp.log
        while read l; do
            #if [ "$(echo $l | grep "RES_${svm}_${gamma}->")" ]; then
                CLEANLINE=$(echo ${l/e/*10^})
                T=$(bc <<< "scale = 6; ${T} + $(echo $l | cut -d':' -f4 | cut -d'+' -f1) ")        
                ST=$(bc <<< "scale = 6; ${ST} + $(echo $l | cut -d':' -f4 | cut -d'+' -f2 | cut -d' ' -f1 | sed -e 's/e/\*10\^/g') ")        
                V=$(bc <<< "scale = 6; ${V} + $(echo $l | cut -d':' -f5 | cut -d'+' -f1) ")        
                SV=$(bc <<< "scale = 6; ${SV} + $(echo $l | cut -d':' -f5 | cut -d'+' -f2 | sed -e 's/e/\*10\^/g')  ") 
                N=$(($N+1))
            #fi    
        done < $SCRIPTPATH/RESULTS/temp.log
        rm $SCRIPTPATH/RESULTS/temp.log
        T=$(bc <<< "scale = 4; ${T} / ${N} ")        
        ST=$(bc <<< "scale = 2; ${ST} / ${N} ")        
        V=$(bc <<< "scale = 4; ${V} / ${N} ")        
        SV=$(bc <<< "scale = 2; ${SV} / ${N} ") 
        echo "FINAL RESULT_${svm}_${gamma}-> T:$T+$ST V:$V+$SV" >> $SCRIPTPATH/RESULTS/Test_sup_$TESTNUM.log
        if (( $(echo "$V > $BV" | bc -l) )); then
            Bsvm=${svm}
            Bgamma=${gamma}
            BV=$V
            BSV=$SV
        fi
        if (( $(echo "($V+$SV) > $BVE" | bc -l) )); then
            BsvmE=${svm}
            BgammaE=${gamma}
            BVE=$V
            BSVE=$SV
        fi
    done
done
echo "BEST RESULT_${Bsvm}_${Bgamma}-> V:$BV+$BSV" >> $SCRIPTPATH/RESULTS/Test_sup_$TESTNUM.log
echo "BEST RESULT_ERR_${BsvmE}_${BgammaE}-> V:$BVE+$BSVE" >> $SCRIPTPATH/RESULTS/Test_sup_$TESTNUM.log
date >> $SCRIPTPATH/RESULTS/Test_sup_$TESTNUM.log

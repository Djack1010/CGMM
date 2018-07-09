#!/bin/bash
#Created by Giacomo Iadarola
#v1.0 - 22/05/18

SCRIPTPATH=$PWD
if [ ! -d $SCRIPTPATH/RESULTS ]; then
    echo "RESULTS folder not found, exiting..."
fi 

rm -f $SCRIPTPATH/RESULTS/memUsage.log

echo "Starting at $(date)" >> $SCRIPTPATH/RESULTS/memUsage.log

MEMUSAGE=0
MEMMAX=0
MEMMAXPER=0
DATEMAX=""
MEMTOT=$(free | grep "Mem" | cut -d' ' -f8)
UPDATE=120

echo ""

while [ "$(ps aux | grep "./run.sh -kfolder" | wc -l )" -gt "1" ]; do
    for i in 11 12 13 14 15 16 17 18 19 20; do
        MEMUSAGE=$(free | grep "Mem" | cut -d' ' -f$i)
        if [ "$MEMUSAGE" ]; then
            break
        fi
    done
    if [ -z "$MEMUSAGE" ]; then
        echo "ERROR, exiting..."
        exit
    elif ! [[ "$MEMUSAGE" =~ ^[0-9]+$ ]]; then
        echo "MEM USAGE: VALUE NOT FOUND..."
        echo "MEM USAGE: VALUE NOT FOUND..." >> $SCRIPTPATH/RESULTS/memUsage.log
        UPDATE=10
    else
        PER=$(bc <<< "scale = 2; ($MEMUSAGE / $MEMTOT) * 100")
        echo "MEM USAGE: $MEMUSAGE ($PER%)"
        echo "MEM USAGE: $MEMUSAGE ($PER%)" >> $SCRIPTPATH/RESULTS/memUsage.log
        if [ "$MEMUSAGE" -ge "$MEMMAX" ];then
            MEMMAX=$MEMUSAGE
            MEMMAXPER=$(bc <<< "scale = 2; ($MEMUSAGE / $MEMTOT) * 100")
            DATEMAX=$(date)
        fi
        UPDATE=120
    fi
    echo "MAX USAGE: $MEMMAX ($MEMMAXPER%) at $DATEMAX"
    sleep $UPDATE
    echo -e "\033[3A"
done

echo "MEM USAGE: $MEMUSAGE ($MEMMAXPER%) at $(date)" >> $SCRIPTPATH/RESULTS/memUsage.log
echo "Finishing at $(date)" >> $SCRIPTPATH/RESULTS/memUsage.log

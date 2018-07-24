#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
PIDRUN=$$

function UsageInfo {
    echo -e "USAGE: [ -update UP ] [ -user USER ] [ -pid PID ] [ -max MAXMEM ] [ -help ]"
    exit
}

function upMemUsage {
    CPUUSAGE=$(top -b -n 1 -u $USER | awk 'NR>7 { sum += $9; } END { print sum; }' )
    MEMUSAGE=$(top -b -n 1 -u $USER | awk 'NR>7 { sum += $10; } END { print sum; }')
    NMAX=0
    if (( $(echo "$MEMUSAGE > $MAXMEM" | bc -l) )); then
        echo "MAX MEM USAGE LIMIT REACHED --> MEM: $MEMUSAGE% > $MAXMEM% at $(date)"
        echo "MAX MEM USAGE LIMIT REACHED --> MEM: $MEMUSAGE% > $MAXMEM% at $(date)" >> ~/logs/usageLog.txt
        if [ "$PIDMON" ]; then
            kill -15 $PIDMON
            echo "MAX MEM USAGE LIMIT REACHED --> killing $PIDMON at $(date)"
            echo "MAX MEM USAGE LIMIT REACHED --> killing $PIDMON at $(date)" >> ~/logs/usageLog.txt
            PIDMON=""
        fi
    fi
    echo "CPU: $CPUUSAGE%       "
    echo "MEM: $MEMUSAGE%       "
    if (( $(echo "$CPUUSAGE > $CPUMAXUS" | bc -l) )); then
        CPUMAXUS=$CPUUSAGE
        MAXDATE=$(date)
        NMAX=1
    fi
    if (( $(echo "$MEMUSAGE > $MEMMAXUS" | bc -l) )); then
        MEMMAXUS=$MEMUSAGE
        MAXDATE=$(date)
        NMAX=1
    fi
    echo "MAX CPU: $CPUMAXUS% and MEM: $MEMMAXUS% at $MAXDATE       "
    echo "CPU: $CPUUSAGE% MEM: $MEMUSAGE% at $(date)" >> ~/logs/usageLog.txt
    if [ "$NMAX" == "1" ]; then
        echo "CPU: $CPUMAXUS% MEM: $MEMMAXUS% at $MAXDATE" >> ~/logs/maxUsageLog.txt
    fi
    echo "See files '~/logs/usageLog.txt' and '~/logs/MAXusageLog.txt' for more info"
    echo -e "\033[5A"
}


mkdir -p ~/logs
rm -f ~/logs/usageLog.txt
rm -f ~/logs/maxUsageLog.txt

myArray=( "$@" )
n=0
while [ $n -lt $# ]; do
    if [[ "${myArray[$n]}" == "-update" ]]; then
        n=$(($n+1))
        if [ -z "${myArray[$n]}" ]; then
            UsageInfo
        else
            UPDATE=${myArray[$n]}
            n=$(($n+1))
        fi
    elif [[ "${myArray[$n]}" == "-user" ]]; then
        n=$(($n+1))
        if [ -z "${myArray[$n]}" ]; then
            UsageInfo
        else
            USER=${myArray[$n]}
            n=$(($n+1))
        fi
    elif [[ "${myArray[$n]}" == "-pid" ]]; then
        n=$(($n+1))
        if [ -z "${myArray[$n]}" ]; then
            UsageInfo
        else
            PIDMON=${myArray[$n]}
            n=$(($n+1))
        fi
    elif [[ "${myArray[$n]}" == "-max" ]]; then
        n=$(($n+1))
        if [ -z "${myArray[$n]}" ]; then
            UsageInfo
        else
            MAXMEM=${myArray[$n]}
            n=$(($n+1))
        fi
    elif [[ "${myArray[$n]}" == "-help" ]]; then
        UsageInfo
    else
        UsageInfo
    fi       
done

if [ -z "$UPDATE" ]; then
    UPDATE=120
fi
echo "UPDATE set to $UPDATE"

if [ -z "$USER" ]; then
    echo "ERROR, NO USER SET, exiting..."
    exit
fi
echo "USER set to $USER"

if [ "$PIDMON" ]; then
    if [ -z "$MAXMEM" ]; then
        MAXMEM=50
    fi
    echo "MONITORING PID $PIDMON and MAXMEM usage set to $MAXMEM"
else
    if [ -z "$MAXMEM" ]; then
        MAXMEM=99
    fi
    echo "MAXMEM set to $MAXMEM"
fi

CPUMAXUS=0
MEMMAXUS=0
MAXDATE=$(date)
#echo -e "\n\n\n"

while true; do
    upMemUsage
    sleep $UPDATE
done

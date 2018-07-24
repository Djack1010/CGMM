#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
PIDRUN=$$

mkdir -p ~/logs
rm -f ~/logs/usageLog.txt
rm -f ~/logs/maxUsageLog.txt

if [ -z "$1" ]; then
    UPDATE=10
else
    UPDATE=$1
fi

if [ -z "$2" ]; then
    USER="giacomo"
else
    USER=$2
fi

function usageInfo {
    echo -e "\033[5A"
    CPUUSAGE=$(top -b -n 1 -u $USER | awk 'NR>7 { sum += $9; } END { print sum; }' )
    MEMUSAGE=$(top -b -n 1 -u $USER | awk 'NR>7 { sum += $10; } END { print sum; }')
    NMAX=0
    echo "CPU: $CPUUSAGE%"
    echo "MEM: $MEMUSAGE%"
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
    echo "MAX CPU: $CPUMAXUS% and MEM: $MEMMAXUS% at $MAXDATE"
    echo "CPU: $CPUUSAGE% MEM: $MEMUSAGE% at $(date)" >> ~/logs/usageLog.txt
    if [ "$NMAX" == "1" ]; then
        echo "CPU: $CPUMAXUS% MEM: $MEMMAXUS% at $MAXDATE" >> ~/logs/maxUsageLog.txt
    fi
    echo "See files '~/logs/usageLog.txt' and '~/logs/MAXusageLog.txt' for more info"
}

CPUMAXUS=0
MEMMAXUS=0
MAXDATE=$(date)
echo -e "\n\n\n"

while true; do
    usageInfo
    sleep $UPDATE
done
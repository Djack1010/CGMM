#!/bin/bash
SCRIPTPATH=$PWD

echo "STARTING $1 at $(date)" >> $SCRIPTPATH/logsRun/clientLog.txt
python3 TestTemplateSup.py -l $2 -e 20 -al 4 -nl 624 -tdp ./data/folder_$1/train/ -vdp ./data/folder_$1/valid/ -ff f$1 2>> $SCRIPTPATH/logsRun/errors$1 1>> $SCRIPTPATH/logsRun/log$1
echo "FINISHING $1 at $(date)" >> $SCRIPTPATH/logsRun/clientLog.txt
if [ "$(cat $SCRIPTPATH/logsRun/errors$1)" ]; then
    echo -e "\nERROR! check $SCRIPTPATH/logsRun/errors$1"
else
    rm $SCRIPTPATH/logsRun/errors$1
fi
exit

#$SCRIPTPATH/data/folder_
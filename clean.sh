#!/bin/bash
SCRIPTPATH=$PWD

for logFile in $(find $SCRIPTPATH -name "*.log" -o -name "*.cgmmOutput"); do
    rm $logFile
done

for FDIR in $SCRIPTPATH/fingerprints/* ; do
    if [ -d $FDIR ]; then
        rm -r $FDIR
    fi
done

for KDIR in $SCRIPTPATH/data/folder_* ; do
    if [ -d $KDIR ]; then
        rm -r $KDIR
    fi
done

for LOGSFILE in $(ls $SCRIPTPATH/logsRun) ; do
    rm $SCRIPTPATH/logsRun/$LOGSFILE
done

if [ -d $SCRIPTPATH/data/KBase_folder ]; then
    rm -r $SCRIPTPATH/data/KBase_folder
fi
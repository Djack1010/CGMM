#!/bin/bash
SCRIPTPATH=$PWD

if [ "$1" == "-soft" ]; then
    SOFT="SET"
fi

for logFile in $(find $SCRIPTPATH -name "*.log" -o -name "*.cgmmOutput"); do
    if [ "$logFile" == "$SCRIPTPATH/Test_sup.log" ] && [ "$SOFT" ]; then
        continue
    else
        rm $logFile
    fi
done

for FDIR in $SCRIPTPATH/fingerprints/* ; do
    if [ -d $FDIR ]; then
        rm -r $FDIR
    fi
done

for LOGSFILE in $(ls $SCRIPTPATH/logsRun) ; do
    rm $SCRIPTPATH/logsRun/$LOGSFILE
done

if [ -z "$SOFT" ]; then
    for KDIR in $SCRIPTPATH/data/folder_* ; do
        if [ -d $KDIR ]; then
            rm -r $KDIR
        fi
    done

    if [ -d $SCRIPTPATH/data/KBase_folder ]; then
        rm -r $SCRIPTPATH/data/KBase_folder
    fi
fi
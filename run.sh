#!/bin/bash
#Created by Giacomo Iadarola
#v1.0 - 22/05/18

function progrBar {
    #[##################################################] (100%)
    PAR=$1
    TOT=$2
    PER=$(bc <<< "scale = 2; ($PAR / $TOT) * 100")
    TEMPPER=$( echo $PER | cut -d'.' -f1)
    COUNT=0
    #echo -ne ""\\r
    #echo -e "\n"
    echo "$PAR out of $TOT - RUNNING: $(jobs | grep "Running" | wc -l) - LAYER: ${LAYERSARRAY[$LAYERIND]}"
    echo -ne "["
    while [ "$TEMPPER" -gt "0" ]; do
        TEMPPER=$(($TEMPPER-2))
        echo -ne "#"
        COUNT=$(($COUNT+1))
    done
    COUNT=$((50-$COUNT))
    for (( c=1; c<$COUNT; c++ )); do
        echo -ne "-"
    done  
    echo -ne "] ($PER%)"
    if ! [ -z "$PIDRUN" ]; then
        TIMERUN=$( ps -o etime= -p "$PIDRUN" )
        echo -ne " TIME:$TIMERUN"
    fi
    echo -e "\033[2A"
}

SCRIPTPATH=$PWD

function UsageInfo {
    echo "USAGE: [ -kfolder KFOLDER ] [ -max MAX ] [ -nl NODELABELS ] [ -l L1:L2:...:LN ] [ -up UPDATE ]"
    echo -e "\t-kfolder KFOLDER\tSplit dataset in K folder and run a K-folder validation"
    echo -e "\t-max MAX\t\tSet maximum number of running parallel instances (DEFAULT 2)"
    echo -e "\t-nl NODELABELS\t\tSet number of node labels"
    echo -e "\t-l L1:L2:...:LN\t\tSet list of layers separated by semicolons (DEFAULT 4:6:8:10)"
    echo -e "\t-up UPDATE\t\tSet frequency updates for running process, in seconds (DEFAULT 60)"
    
    exit
}

if [ "$#" -eq 0 ]; then
    python3 $SCRIPTPATH/TestTemplateSup.py
else
    myArray=( "$@" )
    n=0
    MODE=""
    while [ $n -lt $# ]; do
        if [[ "${myArray[$n]}" == "-kfolder" ]]; then
            MODE="k"
            n=$(($n+1))
            if [ -z "${myArray[$n]}" ]; then
                UsageInfo
            else
                KNUM=${myArray[$n]}
                n=$(($n+1))
            fi
        elif [[ "${myArray[$n]}" == "-max" ]]; then
            n=$(($n+1))
            if [ -z "${myArray[$n]}" ]; then
                UsageInfo
            else
                MAX=${myArray[$n]}
                n=$(($n+1))
            fi
        elif [[ "${myArray[$n]}" == "-nl" ]]; then
            n=$(($n+1))
            if [ -z "${myArray[$n]}" ]; then
                UsageInfo
            else
                NL=${myArray[$n]}
                n=$(($n+1))
            fi
        elif [[ "${myArray[$n]}" == "-l" ]]; then
            n=$(($n+1))
            if [ -z "${myArray[$n]}" ]; then
                UsageInfo
            else
                LAYERSARRAY=($(echo ${myArray[$n]} | sed 's/:/ /g' ))
                n=$(($n+1))
            fi
        elif [[ "${myArray[$n]}" == "-up" ]]; then
            n=$(($n+1))
            if [ -z "${myArray[$n]}" ]; then
                UsageInfo
            else
                UPDATE=${myArray[$n]}
                n=$(($n+1))
            fi
        elif [[ "${myArray[$n]}" == "-help" ]]; then
            UsageInfo
        else
            UsageInfo
        fi       
    done
fi

echo "STARTING run.sh SCRIPT"
echo "" #for progrBar
if [ "$MODE" == "k" ]; then
    if [ ! -d $SCRIPTPATH/data/data_COMPLETE ] || [ -z "$(ls $SCRIPTPATH/data/data_COMPLETE)" ]; then
        echo "ERROR! data/data_COMPLETE not found or empty"
        exit
    fi
    rm -rf $SCRIPTPATH/data/folder_*
    rm -rf $SCRIPTPATH/data/KBase_folder
    FILENUM=$(ls $SCRIPTPATH/data/data_COMPLETE | wc -l)
    KBASE=$((($FILENUM/$KNUM)+1))
    mkdir $SCRIPTPATH/data/KBase_folder
    COUNTER=0
    FOLDER=1
    JOBSARRAY=()
    mkdir $SCRIPTPATH/data/KBase_folder/K${FOLDER}
    for dataFile in $(find $SCRIPTPATH/data/data_COMPLETE -name "*.adjlist" | sort) ; do
        if [ "$COUNTER" == "$KBASE" ]; then
            FOLDER=$(($FOLDER+1))
            mkdir $SCRIPTPATH/data/KBase_folder/K${FOLDER}
            COUNTER=0
        fi
        cp $dataFile $SCRIPTPATH/data/KBase_folder/K${FOLDER}
        COUNTER=$(($COUNTER+1))
    done
    for (( n=1; n<=${KNUM}; n++ )); do
        mkdir $SCRIPTPATH/data/folder_${n}
        mkdir $SCRIPTPATH/data/folder_${n}/train
        mkdir $SCRIPTPATH/data/folder_${n}/valid
        JOBSARRAY+=("${n}")
        for KDIR in $SCRIPTPATH/data/KBase_folder/K* ; do
            if [ -d $KDIR ]; then 
                KFOLDNUM=${KDIR##*K}
                if [ "$KFOLDNUM" == "${n}" ]; then
                    cp -R $KDIR/. $SCRIPTPATH/data/folder_${n}/valid/
                else
                    cp -R $KDIR/. $SCRIPTPATH/data/folder_${n}/train/
                fi
            fi
        done
    done
    PIDRUN=$$
    if [ -z "$MAX" ]; then
        MAX=2
    fi
    mkdir -p $SCRIPTPATH/logsRun

    if [ "${#LAYERSARRAY[@]}" == "0" ]; then
        LAYERSARRAY=("4" "6" "8" "10")
    fi
    LARLENGHT=${#LAYERSARRAY[@]}
    
    if [ -z "$UPDATE" ]; then
        UPDATE=60
    fi
    
    LAYERIND=0
    TOTJOBS=$(($KNUM*$LARLENGHT))
    INDJOBS=0
    IND=0
    while true; do
        if [ "$IND" -ge "$KNUM" ]; then
            while [ "$(jobs | grep "Running" )" ]; do
                PARNOW=$(($INDJOBS-$(jobs | wc -l)))
                progrBar $PARNOW $TOTJOBS
                sleep $UPDATE
            done
            $SCRIPTPATH/clean.sh -soft
            $SCRIPTPATH/calculateResult.sh ${LAYERSARRAY[$LAYERIND]}
            LAYERIND=$(($LAYERIND+1))
            if [ "$LAYERIND" -ge "$LARLENGHT" ]; then
                break
            else
                IND=0
            fi
        elif [ "$(jobs | grep "Running" | wc -l)" -lt "$MAX" ]; then
            #echo "$IND out of $KNUM - JOBS RUNNING: $(jobs | wc -l)"
            $SCRIPTPATH/oneInstance.sh ${JOBSARRAY[$IND]} ${LAYERSARRAY[$LAYERIND]} $NL &
            IND=$(($IND+1))
            INDJOBS=$(($INDJOBS+1))
        else
            #echo "BUSY SITUATION - JOBS RUNNING: $(jobs | wc -l)"
            PARNOW=$(($INDJOBS-$(jobs | wc -l)))
            progrBar $PARNOW $TOTJOBS
            sleep $UPDATE
        fi
    done
fi

echo -e "\n\nENDING run.sh SCRIPT"
exit

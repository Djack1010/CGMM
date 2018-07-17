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
    if [ "$MODE" == "k" ]; then
        echo "$PAR out of $TOT - RUNNING: $(jobs | grep "Running" | wc -l) - LAYER: ${LAYERSARRAY[$LAYERIND]}"
    elif [ "$MODE" == "g" ]; then
        echo "$PAR out of $TOT - RUNNING: $(jobs | grep "Running" | wc -l) - LAYER: ${LAYERSARRAY[$PAR]}"
    fi
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
    echo -e "USAGE: -kfolder KFOLDER | -graph2vec \n[ -max MAX ] [ -nl NODELABELS ] [ -l L1:L2:...:LN ] [ -up UPDATE ] [ -n NAME ] [ -dp D_PATH ]"
    echo -e "\t-kfolder KFOLDER\tSplit dataset in K folder and run a K-folder validation"
    echo -e "\t-max MAX\t\tMAX number of running parallel instances (K-fold ONLY, DEFAULT 2)"
    echo -e "\t-n NAME\t\tSet a name for the output vector (graph2vec ONLY)"
    echo -e "\t-dp D_PATH\t\tSet the data path (graph2vec ONLY)"
    echo -e "\t-nl NODELABELS\t\tSet number of node labels"
    echo -e "\t-l L1:L2:...:LN\t\tSet list of layers separated by semicolons (DEFAULT 4:6:8:10)"
     echo -e "\t-c C\t\tSet C value (DEFAULT 20)"
    echo -e "\t-up UPDATE\t\tSet frequency updates for running process, in seconds (DEFAULT 60)"
    
    exit
}

if [ "$#" -eq 0 ]; then
    UsageInfo
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
        elif [[ "${myArray[$n]}" == "-graph2vec" ]]; then
            MODE="g"
            n=$(($n+1))
        elif [[ "${myArray[$n]}" == "-max" ]]; then
            n=$(($n+1))
            if [ -z "${myArray[$n]}" ]; then
                UsageInfo
            else
                MAX=${myArray[$n]}
                n=$(($n+1))
            fi
        elif [[ "${myArray[$n]}" == "-dp" ]]; then
            n=$(($n+1))
            if [ -z "${myArray[$n]}" ]; then
                UsageInfo
            else
                DATAPATH="-dp ${myArray[$n]}"
                n=$(($n+1))
            fi
        elif [[ "${myArray[$n]}" == "-c" ]]; then
            n=$(($n+1))
            if [ -z "${myArray[$n]}" ]; then
                UsageInfo
            else
                CVALUE=${myArray[$n]}
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
        elif [[ "${myArray[$n]}" == "-n" ]]; then
            n=$(($n+1))
            if [ -z "${myArray[$n]}" ]; then
                UsageInfo
            else
                NAME=${myArray[$n]}
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

if [ -z "$NL" ]; then
    echo "ERROR, set -nl parameter, exiting..."
    exit
fi
if [ -z "$CVALUE" ]; then
    CVALUE=20
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
            $SCRIPTPATH/oneInstance.sh ${JOBSARRAY[$IND]} ${LAYERSARRAY[$LAYERIND]} $NL $CVALUE &
            IND=$(($IND+1))
            INDJOBS=$(($INDJOBS+1))
        else
            #echo "BUSY SITUATION - JOBS RUNNING: $(jobs | wc -l)"
            PARNOW=$(($INDJOBS-$(jobs | wc -l)))
            progrBar $PARNOW $TOTJOBS
            sleep $UPDATE
        fi
    done
elif [ "$MODE" == "g" ]; then
    PIDRUN=$$
    mkdir -p $SCRIPTPATH/logsRun
    mkdir -p $SCRIPTPATH/RESULTS
    if [ -z "$NAME" ]; then
        echo "ERROR, set -n parameter, exiting..."
        exit
    fi
    if [ "${#LAYERSARRAY[@]}" == "0" ]; then
        LAYERSARRAY=("2" "4" "6" "8" "10")
    fi
    LARLENGHT=${#LAYERSARRAY[@]}
    
    for (( c=0; c<$LARLENGHT; c++ )); do
        #progrBar $c $LARLENGHT
        echo "Vectorization $c out of $(($LARLENGHT-1)) - layers ${LAYERSARRAY[$c]} - $(date)"
        python3 Graph2Vector.py -n $NAME -nl $NL -l ${LAYERSARRAY[$c]} -C $CVALUE $DATAPATH 2>> $SCRIPTPATH/logsRun/errorsLay${LAYERSARRAY[$c]} 1>> $SCRIPTPATH/logsRun/logLay${LAYERSARRAY[$c]}
        if [ "$(cat $SCRIPTPATH/logsRun/errorsLay${LAYERSARRAY[$c]})" ]; then
            echo -e "\nERROR! check $SCRIPTPATH/logsRun/errorsLay${LAYERSARRAY[$c]}, exiting..."
            exit
        else
            rm $SCRIPTPATH/logsRun/errorsLay${LAYERSARRAY[$c]}
        fi
    done
fi

echo -e "\n\nENDING run.sh SCRIPT"
exit


SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

rm -f $SCRIPTPATH/temp_*
rm -f $SCRIPTPATH/predictions_wNames.txt
if [ ! -f $SCRIPTPATH/predStandard.txt ]; then
    echo "predStandard.txt does not exist, exiting..."
    exit
elif [ ! -f $SCRIPTPATH/predDropStd.txt ]; then
    echo "predDropStd.txt does not exist, exiting..."
    exit
elif [ ! -f $SCRIPTPATH/predDropStd.txt ]; then
    echo "predDropStd.txt does not exist, exiting..."
    exit
fi
paste $SCRIPTPATH/predStandard.txt $SCRIPTPATH/predDropStd.txt >> $SCRIPTPATH/temp_predTot.txt
paste $SCRIPTPATH/temp_predTot.txt $SCRIPTPATH/files.txt >> $SCRIPTPATH/predictions_wNames.txt
rm $SCRIPTPATH/temp_predTot.txt

line=1
tot=$(cat $SCRIPTPATH/predictions_wNames.txt | wc -l)
if [ -z "$1" ]; then
    scaleDiff=0.005
    scaleName=005
else
    scaleDiff=$1
    scaleName=$(echo $scaleDiff | sed "s/0\.//")
fi

rm -f $SCRIPTPATH/result${scaleName}.txt

while read l; do
    echo -ne "->    Analyzed $line/$tot lines      "\\r
    line=$(($line+1))
    VAL1=$(echo $l | cut -d' ' -f1)
    VAL2=$(echo $l | cut -d' ' -f2)
    VAL21=$(echo $VAL2 | cut -d'+' -f1)
    VAL22=$(echo $VAL2 | cut -d'+' -f2)
    VAL3=$(bc <<< "scale=4; $VAL1 - $VAL21")
    VAL4=${VAL3#-}
    if (( $(echo "$VAL4 < $scaleDiff" |bc -l) )); then
        echo $l >> $SCRIPTPATH/result${scaleName}.txt 
    fi
done < $SCRIPTPATH/predictions_wNames.txt
echo "DONE!"
SELECTED=$(cat result${scaleName}.txt | wc -l)
echo "INFO -> selected $SELECTED files out of $tot - precision $scaleDiff"
ONE=$(cat $SCRIPTPATH/result${scaleName}.txt | grep "^1.0000 " | wc -l)
ZERO=$(cat $SCRIPTPATH/result${scaleName}.txt | grep "^0.0000 " | wc -l)
MISC=$(($SELECTED - $ONE - $ZERO))
echo "ONE: $ONE - ZERO: $ZERO - OTHER: $MISC"
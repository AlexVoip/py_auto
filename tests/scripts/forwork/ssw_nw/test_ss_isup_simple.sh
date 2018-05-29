#!/bin/bash

# Пути
SRC_PATH=~/test/ss_isup_simple
TEMP_PATH=~/test/temp
mkdir $TEMP_PATH/ss_isup_simple
LOG_PATH=~/test/log
SIPP_PATH=~/sipp
FUNC_PATH=~/test/func_lib

source $FUNC_PATH/isup_func_lib.sh


SIPP_IP=$3
REM_IP_PORT=$1
REM_IP_PORT2=$2

NUM_CALLING=654
NUM_CALLED=123
NATURE_CALLING=3
NATURE_CALLED=3

SIPP_PORT_1=$4
SIPP_PORT_2=$5

NCI_ABCD=0000
NCI_EFGH=0000
FCI_ABCD_1=0000
FCI_EFGH_1=0110
FCI_ABCD_2=0000
FCI_EFGH_2=0000
CPC_2_IAM=1010
TMR_1=0000
TMR_2=0011

CPC_IJKL=1000
CPC_MNOP=0000

touch $TEMP_PATH/ss_isup_simple/isup_inj.csv		# Создание инжекционного файла
touch $SRC_PATH/uac_isup_main.xml 			# Создание файла сценария uac
touch $SRC_PATH/uas_isup_main.xml 			# Создание файла сценария uas

# Заполнение инжекционного файла

echo "SEQUENTIAL" >> $TEMP_PATH/ss_isup_simple/isup_inj.csv
echo "$NUM_CALLING;$NUM_CALLED" >> $TEMP_PATH/ss_isup_simple/isup_inj.csv

# Формирование UAC

Full_seq

cat $SRC_PATH/uac_isup_1.txt >> $SRC_PATH/uac_isup_main.xml
echo "$FULL_SEQ" >> $SRC_PATH/uac_isup_main.xml
cat $SRC_PATH/uac_isup_2.txt >> $SRC_PATH/uac_isup_main.xml

# Формирование UAS

# Формирование полных последовательностей

CPC

full_uas_183='\x06\x12\x'$CPC_HEX'\x00'

full_uas_180='\x2c\x01\x01\x11\x02\x16\x'$CPC_HEX'\x00'

full_uas_200='\x07\x16\x'$CPC_HEX'\x00'

# Заполнение файла сценария uas

cat $SRC_PATH/uas_isup_1.txt >> $SRC_PATH/uas_isup_main.xml
echo "$full_uas_183" >> $SRC_PATH/uas_isup_main.xml
cat $SRC_PATH/uas_isup_2.txt >> $SRC_PATH/uas_isup_main.xml
echo "$full_uas_180" >> $SRC_PATH/uas_isup_main.xml
cat $SRC_PATH/uas_isup_3.txt >> $SRC_PATH/uas_isup_main.xml
echo "$full_uas_200" >> $SRC_PATH/uas_isup_main.xml
cat $SRC_PATH/uas_isup_4.txt >> $SRC_PATH/uas_isup_main.xml

# Запуск sipp сценариев

screen -dmS UAS $SIPP_PATH/sipp -sf $SRC_PATH/uas_isup_main.xml -timeout 15 -timeout_error -s $NUM_CALLING -r 1 -l 1 -m 1 -i $SIPP_IP -p $SIPP_PORT_2
sleep 1
$SIPP_PATH/sipp -sf $SRC_PATH/uac_isup_main.xml -timeout 18 -timeout_error -s $NUM_CALLED -inf $TEMP_PATH/ss_isup_simple/isup_inj.csv -r 1 -l 1 -m 1 -i $SIPP_IP -p $SIPP_PORT_1 $REM_IP_PORT

  if test $? -ne 0
      then 
          echo "call FAILED!!!"
      else 
          echo "call SUCCESSFUL" 
  fi

# Удаление временных файлов

rm $TEMP_PATH/ss_isup_simple/isup_inj.csv 
rm $SRC_PATH/uac_isup_main.xml 
rm $SRC_PATH/uas_isup_main.xml 



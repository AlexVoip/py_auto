#!/bin/bash

# Пути
AUDIO=../test/audio
SRC_PATH=~/test/ss_ct_by_refer
TEMP_PATH=~/test/temp
mkdir $TEMP_PATH/ss_ct_by_refer
LOG_PATH=~/test/log
SIPP_PATH=~/sipp

# Лог
cp /dev/null $LOG_PATH/ss_ct_by_refer/log.txt

#				Заполнение переменных

IP_A=$1
IP_BC=$2

IP_SBC_A=$3

IP_PORT_SBC_B=$4
IP_PORT_SBC_C=$5

#DEFAULT inserting variables

#IP_A="192.168.1.10"
#IP_BC="192.168.2.10"

#IP_SBC_A="192.168.1.2"

#IP_PORT_SBC_B="192.168.2.2:5060"
#IP_PORT_SBC_C="192.168.2.2:5061"

#DEFAULT

PORT_SBC_AB=5064	# порт incoming server первого транка, ведущий к B (для А), receives call from sipp
PORT_SBC_AC=5061	# порт incoming server второго транка, ведущий с C (для А), receives call from sipp

port_A=5060            #sipp port A	
port_B=5064            #sipp port B
port_C=5063            #sipp port C

num_A=123
num_B=124
num_C=125

#				Формирование и заполнение инжекционных файлов

touch $TEMP_PATH/ss_codec_support/A.csv
touch $TEMP_PATH/ss_codec_support/B.csv
touch $TEMP_PATH/ss_codec_support/C.csv

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_ct_by_refer/A.csv
echo "$num_A;$num_B;$num_C;$PORT_SBC_AB;$PORT_SBC_AC;$AUDIO" >> $TEMP_PATH/ss_ct_by_refer/A.csv

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_ct_by_refer/B.csv
echo "$num_B;$num_A;$num_C" >> $TEMP_PATH/ss_ct_by_refer/B.csv

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_ct_by_refer/C.csv
echo "$num_C;$num_A;$num_B;$TEMP_PATH/ss_ct_by_refer/C2.csv" >> $TEMP_PATH/ss_ct_by_refer/C.csv

echo "SEQUENTIAL;" > $TEMP_PATH/ss_ct_by_refer/C2.csv

#				Запуск сценариев

#screen -dmS B $SRC_PATH/sbctest_ct_by_refer_B.sh $IP_BC $IP_PORT_SBC_B $port_B $num_B $num_C
$SRC_PATH/sbctest_ct_by_refer_B.sh $IP_BC $IP_PORT_SBC_B $port_B $num_B $num_C&

#screen -dmS C $SRC_PATH/sbctest_ct_by_refer_C.sh $IP_BC $IP_PORT_SBC_C $port_C $num_B $num_C
$SRC_PATH/sbctest_ct_by_refer_C.sh $IP_BC $IP_PORT_SBC_C $port_C $num_B $num_C&


sleep 1

$SIPP_PATH/sipp $IP_SBC_A:$PORT_SBC_AB -sf $SRC_PATH/uac_A_bug44768.xml -inf $TEMP_PATH/ss_ct_by_refer/A.csv -mi $IP_A -nd -i $IP_A -p $port_A -timeout 30 -timeout_error -l 1 -r 1 -m 1

screen -r B

  if test $? -ne 0
      then 
          echo "A FAILED!!!" >> $LOG_PATH/ss_ct_by_refer/log.txt
      else 
          echo "A SUCCESSFUL" >> $LOG_PATH/ss_ct_by_refer/log.txt   
  fi

#				Удаление инжекционных файлов

rm $TEMP_PATH/ss_ct_by_refer/A.csv
rm $TEMP_PATH/ss_ct_by_refer/B.csv
rm $TEMP_PATH/ss_ct_by_refer/C.csv


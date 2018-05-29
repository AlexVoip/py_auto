#!/bin/bash

# Пути
SRC_PATH=~/test/ss_codec_support
TEMP_PATH=~/test/temp
mkdir $TEMP_PATH/ss_codec_support
LOG_PATH=~/test/log
SIPP_PATH=~/sipp

cp /dev/null $LOG_PATH/ss_codec_support/cod_supp_log.txt

#				Заполнение переменных

SSW_IP_PORT=$1
SSW_IP_PORT2=$2
SIPP_IP=$3

#DEFAULT

num_A=200110
num_B=200111

port_A=$4
port_B=$5

#ssw_dom_A=radiususer
#ssw_dom_B=voip.local

ssw_dom_A=dima.domen
ssw_dom_B=dima.domen

#				Формирование и заполнение инжекционных файлов

touch $TEMP_PATH/ss_codec_support/A.csv
touch $TEMP_PATH/ss_codec_support/B.csv

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_codec_support/A.csv
echo "$num_A;$ssw_dom_A;$num_B;" >> $TEMP_PATH/ss_codec_support/A.csv

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_codec_support/B.csv
echo "$num_B;$ssw_dom_B;$num_A;" >> $TEMP_PATH/ss_codec_support/B.csv

#screen -dmS B 

$SRC_PATH/uas_ss_cod_supp.sh $SSW_IP_PORT2 $SIPP_IP $port_B $num_B

sleep 3
$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/uac_cod_supp.xml -inf $TEMP_PATH/ss_codec_support/A.csv -mi $SIPP_IP -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_A -s $num_A -ap $num_A -timeout 10 -timeout_error

  if test $? -ne 0
      then 
          REZULT="call FAILED!!!"
      else 
          REZULT="call SUCCESSFUL"   
  fi




#				Удаление инжекционных файлов

rm $TEMP_PATH/ss_codec_support/A.csv
rm $TEMP_PATH/ss_codec_support/B.csv

echo $REZULT


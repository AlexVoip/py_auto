#!/bin/bash

# Пути
SRC_PATH=~/test/ss_ct_by_refer
TEMP_PATH=~/test/temp
mkdir $TEMP_PATH/ss_ct_by_refer
LOG_PATH=~/test/log
SIPP_PATH=~/sipp

# Переменные

IP_BC=$1
IP_PORT_SBC_B=$2
port_B=$3
num_B=$4
num_C=$5

#				Запуск сценариев

$SIPP_PATH/sipp $IP_PORT_SBC_B -sf $SRC_PATH/uas_B.xml -inf $TEMP_PATH/ss_ct_by_refer/B.csv -mi $IP_BC -nd -i $IP_BC -p $port_B -timeout 30 -timeout_error -l 1 -r 1 -m 1

  if test $? -ne 0
      then 
          echo "B FAILED!!!" >> $LOG_PATH/ss_ct_by_refer/log.txt
      else 
          echo "B SUCCESSFUL" >> $LOG_PATH/ss_ct_by_refer/log.txt   
  fi


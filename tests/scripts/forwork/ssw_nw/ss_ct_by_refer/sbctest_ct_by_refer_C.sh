#!/bin/bash

# Пути
SRC_PATH=~/test/ss_ct_by_refer
TEMP_PATH=~/test/temp
mkdir $TEMP_PATH/ss_ct_by_refer
LOG_PATH=~/test/log
SIPP_PATH=~/sipp

# Переменные

IP_BC=$1
IP_PORT_SBC_C=$2
port_C=$3
num_B=$4
num_C=$5

#				Запуск сценариев

$SIPP_PATH/sipp $IP_PORT_SBC_C -sf $SRC_PATH/uas_C1.xml -inf $TEMP_PATH/ss_ct_by_refer/C.csv -mi $IP_BC -nd -i $IP_BC -p $port_C -timeout 200 -timeout_error -l 1 -r 1 -m 1

  if test $? -ne 0
      then 
          echo "C1 FAILED!!!" >> $LOG_PATH/ss_ct_by_refer/log.txt
      else 
          echo "C1 SUCCESSFUL" >> $LOG_PATH/ss_ct_by_refer/log.txt   
  fi

$SIPP_PATH/sipp $IP_PORT_SBC_C -sf $SRC_PATH/uas_C2.xml -inf $TEMP_PATH/ss_ct_by_refer/C.csv -mi $IP_BC -nd -i $IP_BC -p $port_C -timeout 10 -timeout_error -l 1 -r 1 -m 1

  if test $? -ne 0
      then 
          echo "C2 FAILED!!!" >> $LOG_PATH/ss_ct_by_refer/log.txt
      else 
          echo "C2 SUCCESSFUL" >> $LOG_PATH/ss_ct_by_refer/log.txt   
  fi

$SIPP_PATH/sipp $IP_PORT_SBC_C -sf $SRC_PATH/uas_C3.xml -inf $TEMP_PATH/ss_ct_by_refer/C2.csv -mi $IP_BC -nd -i $IP_BC -p $port_C -timeout 10 -timeout_error -l 1 -r 1 -m 1

  if test $? -ne 0
      then 
          echo "C3 FAILED!!!" >> $LOG_PATH/ss_ct_by_refer/log.txt
      else 
          echo "C3 SUCCESSFUL" >> $LOG_PATH/ss_ct_by_refer/log.txt   
  fi

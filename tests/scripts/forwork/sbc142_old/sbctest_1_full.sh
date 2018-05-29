#!/bin/bash

# Тест SBC. Версия ПО 1.4.2.

# Переменные командной строки
SBC_A1=192.168.118.90:5060 
SBC_A2=192.168.118.90:5062 
SIPP_IP_A=192.168.118.10 
SIPP_P_A1=5060 
SIPP_P_A2=5062
SBC_T1=192.168.116.90:5060
SBC_T2=192.168.116.90:5062
SIPP_IP_T=192.168.116.10 
SIPP_P_T1=5060 
SIPP_P_T2=5062
SBC_N1=192.168.117.90:5060 
SBC_N2=192.168.119.90:5060 
SIPP_IP_N1=192.168.117.10 
SIPP_P_N1=5060
SIPP_P_N2=5062 
SIPP_IP_N2=192.168.119.10 
SIPP_IP_N3=192.168.119.11

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_sbc1_all.txt

# Переменные для подсчета успешных, неуспешных вызовов и номер теста
FAIL_COUNT=0
SUCC_COUNT=0

# Функция подсчета успешных и неуспешных вызовов
REZULT ()
{
  if test $? -ne 0
      then 
          FAIL_COUNT=$(($FAIL_COUNT+1))
          echo Test $COUNT failed >> $TEMP_PATH/results_sbc1_all.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_sbc1_all.txt          
  fi
}

## Registration in UAC mode (support in 1.4.2)

COUNT=1
./sbctest_1.sh $SBC_A1 $SBC_A2 $SIPP_IP_A $SIPP_P_A1 $SIPP_P_A2 
COUNT=2
./sbctest_1_tr.sh $SBC_T1 $SBC_T2 $SIPP_IP_T $SIPP_P_T1 $SIPP_P_T2 
COUNT=3
./sbctest_1_nat.sh $SBC_N1 $SBC_N2 $SIPP_IP_N1 $SIPP_P_N1 $SIPP_P_N2 $SIPP_IP_N2 $SIPP_IP_N3

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

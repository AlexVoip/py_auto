#!/bin/bash

# Тест услуги "Удержание вызова" - CW. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента и один SIP-транк
#              : активированы услуги (выполнен скрипт sswconf_ss_perm.sh)

# Переменные командной строки
# $1 SSW_IP_address
# $2 SIPP_IP_address

# Путь к скриптам
SRC_PATH=~/test/ss_cw
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
# Number C - SIP trunk user
USER_A=200100
USER_B=500100
USER_C=800100
DOM_A=voip.local
DOM_B=$DOM_A
DOM_C=$1
PORT_A=5060
PORT_B=5063
PORT_C=6060
HOLD_KOD=94
SS_KOD=43

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_B-hold.csv
sudo rm $TEMP_PATH/$USER_B-cw.csv
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_C-$USER_B.csv
sudo rm $TEMP_PATH/$USER_A.csv
sudo rm $TEMP_PATH/$USER_C.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_cw.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_B;$DOM_B;*$HOLD_KOD#;*#$HOLD_KOD#;#$HOLD_KOD#;" > $TEMP_PATH/$USER_B-hold.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;*$SS_KOD#;*#$SS_KOD#;#$SS_KOD#;" > $TEMP_PATH/$USER_B-cw.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;$USER_B;" > $TEMP_PATH/$USER_C-$USER_B.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;" > $TEMP_PATH/$USER_A.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;" > $TEMP_PATH/$USER_C.csv

# Переменные для подсчета успешных, неуспешных вызовов и номер теста
FAIL_COUNT=0
SUCC_COUNT=0
COUNT=0

# Функция подсчета успешных и неуспешных вызовов
REZULT ()
{
  if test $? -ne 0
      then 
          FAIL_COUNT=$(($FAIL_COUNT+1))
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_cw.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_cw.txt          
  fi
}

# Registration users
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B-cw.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

COUNT=1
# Activate Hold, CW and check CW
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_B-hold.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_B-cw.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_B-cw.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

COUNT=2
# Waiting call on B? Reject by flash 0
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_cw2_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/6-uac_ssw.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error -sleep 5 & 
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_cw2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
#REZULT
#sleep 2

COUNT=3
# Waiting call on B? Reject by flash 1
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_cw1_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_cw1.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_cw1_3.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error -sleep 5
REZULT
sleep 2

COUNT=4
# Waiting call on B? Reject by flash 2
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_cw3_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_cw3_3.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error -sleep 5 &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_cw2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=5
# Waiting call on B, Callback
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_cw1_3.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error -sleep 7 &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_cw1_3.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 2 &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_ctr2_2_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_cw4_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=6
# Deactivate 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_B-cw.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error      
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_B-hold.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

# Unregistration
COUNT=0
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B-cw.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT 

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_B-hold.csv
sudo rm $TEMP_PATH/$USER_B-cw.csv
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_C-$USER_B.csv
sudo rm $TEMP_PATH/$USER_A.csv
sudo rm $TEMP_PATH/$USER_C.csv

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi
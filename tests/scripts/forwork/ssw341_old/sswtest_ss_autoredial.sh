#!/bin/bash

# Тест autoredial. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента 
#              : активированы услуги (выполнен скрипт sswconf_ss_perm.sh)

# Переменные командной строки
# $1 SSW_cocon_user
# $2 SSW_cocon_password
# $3 SSW_domain
# $4 SSW_IP_address
# $5 SIPP_IP_address
# $6 Number of SIP USER A

# Путь к скриптам
SRC_PATH=~/test/ss_autoredial
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Конфигурируем услугу и таймера
$SRC_PATH/sswconf_autored1.sh $1 $2 $3 $4 $6
$SRC_PATH/sswconf_timer.sh $1 $2 $3 $4
# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
USER_A=$6
USER_B=500100
DOM_A=voip.local
DOM_B=$DOM_A
PORT_A=5060
PORT_B=5063
PORT_C=6060
# Not registered
USER_NR=200110
DOM_NR=$DOM_A
PORT_NR=$PORT_A
AUTORED_BUSY_KOD=37
AUTORED_ALL_KOD=38
CFOOS_KOD=24

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A.csv
sudo rm $TEMP_PATH/$USER_B.csv
sudo rm $TEMP_PATH/$USER_NR.csv
sudo rm $TEMP_PATH/$USER_A-busy.csv
sudo rm $TEMP_PATH/$USER_A-all.csv
sudo rm $TEMP_PATH/$USER_A-$USER_NR.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_autoredial.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;" > $TEMP_PATH/$USER_A.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;" > $TEMP_PATH/$USER_B.csv
echo "SEQUENTIAL;
$USER_NR;$DOM_NR;*$CFOOS_KOD*$USER_B#;#$CFOOS_KOD#" > $TEMP_PATH/$USER_NR.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$AUTORED_BUSY_KOD*$USER_B#;" > $TEMP_PATH/$USER_A-busy.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$AUTORED_ALL_KOD*$USER_B#;" > $TEMP_PATH/$USER_A-all.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$AUTORED_ALL_KOD*$USER_NR#;" > $TEMP_PATH/$USER_A-$USER_NR.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_autoredial.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_autoredial.txt          
  fi
}

# Тест
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_NR.csv -mi $5 -s $USER_NR -ap $USER_NR -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_NR -recv_timeout 200s -timeout_error
REZULT

COUNT=1
# busy at all
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans486.xml -mi $5 -m 6 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uac_ans480.xml -inf $TEMP_PATH/$USER_A-busy.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 
sleep 3

COUNT=2
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uac_field2_r1i.xml -inf $TEMP_PATH/$USER_A-busy.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 3 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans486.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error 
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans600.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans486.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans600.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans486.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_send_bye.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT 
sleep 3

COUNT=3
# free after not ans
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uac_field2_r1i.xml -inf $TEMP_PATH/$USER_A-all.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 3 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_cancel.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_send_bye.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT 
sleep 3

COUNT=4
# to not reg
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uac_ans480.xml -inf $TEMP_PATH/$USER_A-$USER_NR.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 

COUNT=5
# with cfoos to busy and free later
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_NR.csv -mi $5 -s $USER_NR -ap $USER_NR -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_NR -recv_timeout 200s -timeout_error
REZULT 
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_NR.csv -mi $5 -s $USER_NR -ap $USER_NR -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_NR -recv_timeout 200s -timeout_error
REZULT 
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_NR.csv -mi $5 -s $USER_NR -ap $USER_NR -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_NR -recv_timeout 200s -timeout_error
REZULT 

# free after busy after cfoos
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uac_field2_r1i.xml -inf $TEMP_PATH/$USER_A-$USER_NR.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 3 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans486.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans600.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans486.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans600.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans486.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_send_bye.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT 
sleep 3

# cfoos deactivate
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_NR.csv -mi $5 -s $USER_NR -ap $USER_NR -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_NR -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_NR.csv -mi $5 -s $USER_NR -ap $USER_NR -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_NR -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_NR.csv -mi $5 -s $USER_NR -ap $USER_NR -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_NR -recv_timeout 200s -timeout_error
REZULT


COUNT=0
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT	

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A.csv 
sudo rm $TEMP_PATH/$USER_B.csv 
sudo rm $TEMP_PATH/$USER_NR.csv
sudo rm $TEMP_PATH/$USER_A-busy.csv
sudo rm $TEMP_PATH/$USER_A-all.csv
sudo rm $TEMP_PATH/$USER_A-$USER_NR.csv

# Возвращаем исходные настройки
$SRC_PATH/sswconf_autored2.sh $1 $2 $3 $4 $6

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

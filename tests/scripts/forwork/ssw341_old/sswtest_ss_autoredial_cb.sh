#!/bin/bash

# Тест ДВО автодозвон с отзвоном. Версия ПО 3.3.
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
SRC_PATH=~/test/ss_autoredial_cb
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Конфигурируем услугу
$SRC_PATH/sswconf_autored1cb.sh $1 $2 $3 $4 $6

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
USER_A=$6
USER_B=500100
DOM_A=voip.local
DOM_B=$DOM_A
PORT_A=5060
PORT_B=5063
AUTORED_KOD=39


# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A.csv
sudo rm $TEMP_PATH/$USER_B.csv
sudo rm $TEMP_PATH/$USER_A-cb1.csv
sudo rm $TEMP_PATH/$USER_A-cb2.csv
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_autoredial_cb.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;" > $TEMP_PATH/$USER_A.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;" > $TEMP_PATH/$USER_B.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$AUTORED_KOD#;" > $TEMP_PATH/$USER_A-cb1.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$AUTORED_KOD*$USER_B#;" > $TEMP_PATH/$USER_A-cb2.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_autoredial_cb.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_autoredial_cb.txt          
  fi
}

# Тест
# Register users
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

COUNT=1
# Call to busy user B
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans486.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/6-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=2
# Callback with last dialed number (user B busy two times)
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_A-cb1.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/3-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans486.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error 
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans600.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error 
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_r1i.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error 
sleep 2

COUNT=3
# Callback with dial number B (user B busy one time, user A busy one time)
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_A-cb2.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans486.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error  
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_r1i.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ans486.xml -mi $5 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error 
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/3-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error

COUNT=0
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT	

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A.csv
sudo rm $TEMP_PATH/$USER_B.csv
sudo rm $TEMP_PATH/$USER_A-cb1.csv
sudo rm $TEMP_PATH/$USER_A-cb2.csv
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv

# Возвращаем исходные настройки
$SRC_PATH/sswconf_autored3.sh $1 $2 $3 $4 $6

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

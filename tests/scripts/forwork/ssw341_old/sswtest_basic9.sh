#!/bin/bash

# Тест базовых вызовов. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента и один SIP-транк

# Переменные командной строки
# $1 SSW_cocon_user
# $2 SSW_cocon_password
# $3 SSW_domain
# $4 SSW_IP_address
# $5 SIPP_IP_address

# Путь к скриптам
SRC_PATH=~/test/basic
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Конфигурируем необходимые таймеры
$SRC_PATH/sswconf_basic1.sh $1 $2 $3 $4

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
# Number C - SIP trunk user
USER_A=200100
USER_B=500100
USER_C=800100
DOM_A=voip.local
DOM_B=radiususer
DOM_C=$4
PORT_A=5060
PORT_B=5063
PORT_C=5066
# Not registered, Unallocated, No such number
USER_NR=200101
USER_UA=200102
USER_NN=2000000

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A.csv
sudo rm $TEMP_PATH/$USER_B.csv
sudo rm $TEMP_PATH/$USER_C.csv
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_A-$USER_C.csv
sudo rm $TEMP_PATH/$USER_B-$USER_A.csv
sudo rm $TEMP_PATH/$USER_B-$USER_C.csv
sudo rm $TEMP_PATH/$USER_C-$USER_A.csv
sudo rm $TEMP_PATH/$USER_C-$USER_B.csv
sudo rm $TEMP_PATH/$USER_A-$USER_NR.csv
sudo rm $TEMP_PATH/$USER_A-$USER_UA.csv
sudo rm $TEMP_PATH/$USER_A-$USER_NN.csv
sudo rm $TEMP_PATH/$USER_B-$USER_NR.csv
sudo rm $TEMP_PATH/$USER_B-$USER_UA.csv
sudo rm $TEMP_PATH/$USER_B-$USER_NN.csv
sudo rm $TEMP_PATH/$USER_C-$USER_NR.csv
sudo rm $TEMP_PATH/$USER_C-$USER_UA.csv
sudo rm $TEMP_PATH/$USER_C-$USER_NN.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_basic.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;" > $TEMP_PATH/$USER_A.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;" > $TEMP_PATH/$USER_B.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;" > $TEMP_PATH/$USER_C.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_C;" > $TEMP_PATH/$USER_A-$USER_C.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;$USER_A;" > $TEMP_PATH/$USER_B-$USER_A.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;$USER_C;" > $TEMP_PATH/$USER_B-$USER_C.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;$USER_A;" > $TEMP_PATH/$USER_C-$USER_A.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;$USER_B;" > $TEMP_PATH/$USER_C-$USER_B.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_NR;" > $TEMP_PATH/$USER_A-$USER_NR.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_UA;" > $TEMP_PATH/$USER_A-$USER_UA.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_NN;" > $TEMP_PATH/$USER_A-$USER_NN.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;$USER_NR;" > $TEMP_PATH/$USER_B-$USER_NR.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;$USER_UA;" > $TEMP_PATH/$USER_B-$USER_UA.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;$USER_NN;" > $TEMP_PATH/$USER_B-$USER_NN.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;$USER_NR;" > $TEMP_PATH/$USER_C-$USER_NR.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;$USER_UA;" > $TEMP_PATH/$USER_C-$USER_UA.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;$USER_NN;" > $TEMP_PATH/$USER_C-$USER_NN.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_basic.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_basic.txt          
  fi
}

# Тест
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/6-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/6-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error

sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/7-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/7-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error



COUNT=$(($COUNT+1))
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/11-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_NR.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/11-uac_ssw.xml -inf $TEMP_PATH/$USER_B-$USER_NR.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/11-uac_ssw.xml -inf $TEMP_PATH/$USER_C-$USER_NR.csv -mi $5 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error 
REZULT

COUNT=$(($COUNT+1))
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/12-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_UA.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error 
REZULT 
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/12-uac_ssw.xml -inf $TEMP_PATH/$USER_B-$USER_UA.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT   
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/12-uac_ssw.xml -inf $TEMP_PATH/$USER_C-$USER_UA.csv -mi $5 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error
REZULT 

COUNT=$(($COUNT+1))
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/13-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_NN.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error 
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/13-uac_ssw.xml -inf $TEMP_PATH/$USER_B-$USER_NN.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error 
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/13-uac_ssw.xml -inf $TEMP_PATH/$USER_C-$USER_NN.csv -mi $5 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error        
REZULT 


sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/8-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/8-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error












                

COUNT=0
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT	

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A.csv
sudo rm $TEMP_PATH/$USER_B.csv
sudo rm $TEMP_PATH/$USER_C.csv
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv 
sudo rm $TEMP_PATH/$USER_A-$USER_C.csv 
sudo rm $TEMP_PATH/$USER_B-$USER_A.csv 
sudo rm $TEMP_PATH/$USER_B-$USER_C.csv 
sudo rm $TEMP_PATH/$USER_C-$USER_A.csv 
sudo rm $TEMP_PATH/$USER_C-$USER_B.csv 
sudo rm $TEMP_PATH/$USER_A-$USER_NR.csv
sudo rm $TEMP_PATH/$USER_A-$USER_UA.csv
sudo rm $TEMP_PATH/$USER_A-$USER_NN.csv
sudo rm $TEMP_PATH/$USER_B-$USER_NR.csv
sudo rm $TEMP_PATH/$USER_B-$USER_UA.csv
sudo rm $TEMP_PATH/$USER_B-$USER_NN.csv
sudo rm $TEMP_PATH/$USER_C-$USER_NR.csv
sudo rm $TEMP_PATH/$USER_C-$USER_UA.csv
sudo rm $TEMP_PATH/$USER_C-$USER_NN.csv

# Возвращаем исходные значения некоторым таймерам
$SRC_PATH/sswconf_basic2.sh $1 $2 $3 $4

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi
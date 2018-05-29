#!/bin/bash

# Тест pickup. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента 
#              : активированы услуги (выполнен скрипт sswconf_ss_perm.sh)

# Переменные командной строки
# $1 SSW_cocon_user
# $2 SSW_cocon_password
# $3 SSW_domain
# $4 SSW_IP_address
# $5 SIPP_IP_address

# Путь к скриптам
SRC_PATH=~/test/ss_pickup
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
USER_A=200100
USER_B=500100
USER_C=200110
USER_D=200111
DOM_A=voip.local
DOM_B=voip.local
DOM_C=voip.local
DOM_D=voip.local
PORT_A=5060
PORT_B=5063
PORT_C=5160
PORT_D=5160
PK_KOD1=07
PK_KOD2=08

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A-$USER_C.csv
sudo rm $TEMP_PATH/$USER_A-$USER_D.csv
sudo rm $TEMP_PATH/$USER_B-pk.csv
sudo rm $TEMP_PATH/$USER_B-pk1.csv
sudo rm $TEMP_PATH/$USER_B-pk2.csv
sudo rm $TEMP_PATH/$USER_B-pkC.csv
sudo rm $TEMP_PATH/$USER_B-pkD.csv
sudo rm $TEMP_PATH/$USER_C.csv
sudo rm $TEMP_PATH/$USER_D.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_pickup.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_C" > $TEMP_PATH/$USER_A-$USER_C.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_D" > $TEMP_PATH/$USER_A-$USER_D.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;*$PK_KOD2#" > $TEMP_PATH/$USER_B-pk.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;*$PK_KOD1*1#" > $TEMP_PATH/$USER_B-pk1.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;*$PK_KOD1*2#" > $TEMP_PATH/$USER_B-pk2.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;*$PK_KOD1*$USER_C#" > $TEMP_PATH/$USER_B-pkC.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;*$PK_KOD1*$USER_D#" > $TEMP_PATH/$USER_B-pkD.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;" > $TEMP_PATH/$USER_C.csv
echo "SEQUENTIAL;
$USER_D;$DOM_D;" > $TEMP_PATH/$USER_D.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_pickup.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_pickup.txt          
  fi
}

# Registration
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B-pk.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_C.csv -mi $5 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_D.csv -mi $5 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_D -recv_timeout 200s -timeout_error     
REZULT
sleep 2

# активируем услугу 
$SRC_PATH/sswconf_pickup1.sh $1 $2 $3 $4 $USER_A $USER_B $USER_C $USER_D

COUNT=1
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pk.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

COUNT=2
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pkC.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

COUNT=3
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pk1.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

COUNT=4
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_D.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pk.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

COUNT=5
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_D.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pkD.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

COUNT=6
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_D.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pk2.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

COUNT=7
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9r-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2r-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pk.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

COUNT=8
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9r-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2r-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pkC.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

COUNT=9
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9r-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2r-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pk1.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

COUNT=10
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9r-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2r-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_D.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pk.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

COUNT=11
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9r-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2r-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_D.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pkD.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

COUNT=12
# free after busy
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/9r-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error  &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/2r-uac_ssw_pk.xml -inf $TEMP_PATH/$USER_A-$USER_D.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 1 &
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_B-pk2.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error -sleep 2
REZULT 
sleep 3

# деактивируем услугу             
$SRC_PATH/sswconf_pickup2.sh $1 $2 $3 $4 $USER_A $USER_B $USER_C $USER_D

# Unregistration
COUNT=0
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B-pk.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error 
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_C.csv -mi $5 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_C -recv_timeout 200s -timeout_error     
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_D.csv -mi $5 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_D -recv_timeout 200s -timeout_error     
REZULT

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-$USER_C.csv
sudo rm $TEMP_PATH/$USER_A-$USER_D.csv
sudo rm $TEMP_PATH/$USER_B-pk.csv
sudo rm $TEMP_PATH/$USER_B-pk1.csv
sudo rm $TEMP_PATH/$USER_B-pk2.csv
sudo rm $TEMP_PATH/$USER_B-pkC.csv
sudo rm $TEMP_PATH/$USER_B-pkD.csv
sudo rm $TEMP_PATH/$USER_C.csv 
sudo rm $TEMP_PATH/$USER_D.csv 

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

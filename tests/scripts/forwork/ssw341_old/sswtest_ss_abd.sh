#!/bin/bash

# Тест услуги "Сокращенный набор" - ABD. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента и один SIP-транк
#              : активированы услуги (выполнен скрипт sswconf_ss_perm.sh)

# Переменные командной строки
# $1 SSW_IP_address
# $2 SIPP_IP_address
# $3 SSW_cocon_user
# $4 SSW_cocon_password
# $5 SSW_domain
# $6 USER_A

# Путь к скриптам
SRC_PATH=~/test/ss_abd
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
ABD_KOD=51

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A-abd.csv
sudo rm $TEMP_PATH/$USER_A-03.csv
sudo rm $TEMP_PATH/$USER_A-10.csv
sudo rm $TEMP_PATH/$USER_B-abd.csv
sudo rm $TEMP_PATH/$USER_A-3.csv
sudo rm $TEMP_PATH/$USER_A-9.csv
sudo rm $TEMP_PATH/$USER_A-abd2.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_abd.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$ABD_KOD#;*#$ABD_KOD#;#$ABD_KOD#;*$ABD_KOD*03*$USER_C#;*#$ABD_KOD*03#;#$ABD_KOD*03#;*$ABD_KOD*10*$USER_B#;*#$ABD_KOD*10#;#$ABD_KOD*10#;" > $TEMP_PATH/$USER_A-abd.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$ABD_KOD#;*#$ABD_KOD#;#$ABD_KOD#;*$ABD_KOD*3*$USER_C#;*#$ABD_KOD*3#;#$ABD_KOD*3#;*$ABD_KOD*9*$USER_B#;*#$ABD_KOD*9#;#$ABD_KOD*9#;" > $TEMP_PATH/$USER_A-abd2.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;**03;" > $TEMP_PATH/$USER_A-03.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;**10;" > $TEMP_PATH/$USER_A-10.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;**3;" > $TEMP_PATH/$USER_A-3.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;**9;" > $TEMP_PATH/$USER_A-9.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;" > $TEMP_PATH/$USER_B-abd.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_abd.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_abd.txt          
  fi
}

# Активируем услугу 100 num
$SRC_PATH/sswconf_abd1.sh $3 $4 $5 $1 $USER_A

# Registration users
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B-abd.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

COUNT=1
# fill 03 and 10 abbreviated numbers
#not used sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
#REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field5.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field8.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
# Check ABD                           
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field6.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=2
# Test
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-10.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-03.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=3
# Deactivate ABD and check after delete numbers
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field10.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error      
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field7.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error      
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error      
REZULT
#not used sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error      
#REZULT

# Deactivation
$SRC_PATH/sswconf_abd2.sh $3 $4 $5 $1 $USER_A
# Активируем услугу 10 num
$SRC_PATH/sswconf_abd3.sh $3 $4 $5 $1 $USER_A

COUNT=4
# fill 3 and 9 abbreviated numbers
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field5.xml -inf $TEMP_PATH/$USER_A-abd2.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field8.xml -inf $TEMP_PATH/$USER_A-abd2.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
# Check ABD                           
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_A-abd2.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field6.xml -inf $TEMP_PATH/$USER_A-abd2.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_A-abd2.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=5
# Test
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-9.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-3.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=6
# Deactivate ABD and check after delete numbers
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field10.xml -inf $TEMP_PATH/$USER_A-abd2.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field7.xml -inf $TEMP_PATH/$USER_A-abd2.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_A-abd2.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT


# Unregistration
COUNT=0
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A-abd.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B-abd.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT	

# Возвращаем исходные значения
$SRC_PATH/sswconf_abd2.sh $3 $4 $5 $1 $USER_A

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-abd.csv
sudo rm $TEMP_PATH/$USER_A-03.csv 
sudo rm $TEMP_PATH/$USER_A-10.csv 
sudo rm $TEMP_PATH/$USER_B-abd.csv
sudo rm $TEMP_PATH/$USER_A-3.csv 
sudo rm $TEMP_PATH/$USER_A-9.csv 
sudo rm $TEMP_PATH/$USER_A-abd2.csv

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

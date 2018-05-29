#!/bin/bash

# Тест услуги "Черный список" - SCR, SCO_black. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента и один SIP-транк
#              : активированы услуги (выполнен скрипт sswconf_ss_perm.sh)

# Переменные командной строки
# $1 SSW_IP_address
# $2 SIPP_IP_address

# Путь к скриптам
SRC_PATH=~/test/ss_scr_sco
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
# Number C and D - SIP trunk user
USER_A=200100
USER_B=500100
USER_C=800100
USER_D=$(($USER_C+1))
DOM_A=voip.local
DOM_B=$DOM_A
DOM_C=$1
DOM_D=$1
PORT_A=5060
PORT_B=5063
PORT_C=6060
PORT_D=6060
SCR_KOD=61
SCO_BL_KOD=63
PIN_A=1111
PIN_B=1111

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A-scrsco.csv 
sudo rm $TEMP_PATH/$USER_B-scrsco.csv 
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_A-$USER_C.csv
sudo rm $TEMP_PATH/$USER_D-$USER_B.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_scrsco.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$SCO_BL_KOD*$PIN_A#;#$SCO_BL_KOD*$PIN_A#;*$SCO_BL_KOD*$PIN_A*0*$USER_C#;*$SCO_BL_KOD*$PIN_A*1*$USER_C#;*$SCO_BL_KOD*$PIN_A*$USER_C#;#$SCO_BL_KOD*$PIN_A*0#;#$SCO_BL_KOD*$PIN_A*1#;#$SCO_BL_KOD*$PIN_A*$USER_C#;" > $TEMP_PATH/$USER_A-scrsco.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;*$SCR_KOD*$PIN_B#;#$SCR_KOD*$PIN_B#;*$SCR_KOD*$PIN_B*0*$USER_C#;*$SCR_KOD*$PIN_B*1*$USER_C#;*$SCR_KOD*$PIN_B*$USER_C#;#$SCR_KOD*$PIN_B*0#;#$SCR_KOD*$PIN_B*1#;#$SCR_KOD*$PIN_B*$USER_C#;" > $TEMP_PATH/$USER_B-scrsco.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_C;" > $TEMP_PATH/$USER_A-$USER_C.csv
echo "SEQUENTIAL;
$USER_D;$DOM_C;$USER_B;" > $TEMP_PATH/$USER_D-$USER_B.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_scrsco.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_scrsco.txt          
  fi
}

# Registration users
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

# Control of deactivation of SCR and SCO features
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error 
REZULT

# Activation of SCO_BL feature to user A 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

# Control extraction of num C from list
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

# Test SCO_BLACK
COUNT=1
# Calls sucsessful to B and C (no numbers in list)
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=2
# Add num in 0 string in list. Must be error
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
# Add num user_C in list by line=1 and test
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field5.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT  
# Calls
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error      
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
# delete USER_C from list by code 0
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field7.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 
# Call to USER_C
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=3
# Add num user_C in list by line=1 and test
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field5.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT  
# Calls 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
# delete USER_C from list by line=1
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field8.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 
# Call to USER_C
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=4
# Add num user_C in list by number and test
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field6.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT  
# Calls 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
# delete USER_C from list by number
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 
# Call to USER_C
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=5
# Deactivation of SCO feature
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 
# Calls to USER_B and USER_C, success
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

# Test SCR
COUNT=6
# Activation of SCR feature to user B
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

# Control extraction of user C number from list
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

# Calls from USER_A and USER_C, success
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_D-$USER_B.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=7
# Add num in 0 string in list. Must be error
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Add num user C in black list (line=1).
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field5.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B, success A, fail D
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_D-$USER_B.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error
REZULT
sleep 3
# Extract number of user C from black list (code=0)
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field7.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B from D
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_D-$USER_B.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=8
# Add num user C in black list (line=1).
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field5.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B, success A, fail D
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_D-$USER_B.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error 
REZULT
sleep 3
# Extract number of user C from black list (line=1)                  
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field8.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B from D
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_D-$USER_B.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=9
# Add num user C in black list (number).
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field6.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B, success A, fail D
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_D-$USER_B.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error
REZULT
sleep 3
# Extract number of user C from black list (number)                  
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B from D
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_D-$USER_B.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error
REZULT
sleep 2


COUNT=10
# Deactivation of SCR feature
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Calls from USER_A and USER_C, success
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_D-$USER_B.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error
REZULT 
sleep 2

# Unregistration
COUNT=0
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT	

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-scrsco.csv
sudo rm $TEMP_PATH/$USER_B-scrsco.csv
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_A-$USER_C.csv
sudo rm $TEMP_PATH/$USER_D-$USER_B.csv

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

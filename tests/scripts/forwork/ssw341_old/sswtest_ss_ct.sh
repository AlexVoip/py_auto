#!/bin/bash

# Тест услуги "Передача вызова" - СТ. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента и один SIP-транк
#              : активированы услуги (выполнен скрипт sswconf_ss_perm.sh)

# Переменные командной строки
# $1 SSW_IP_address
# $2 SIPP_IP_address

# Путь к скриптам
SRC_PATH=~/test/ss_ct
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
SS_KOD=96

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A-hold.csv
sudo rm $TEMP_PATH/$USER_A-ct.csv
sudo rm $TEMP_PATH/$USER_A-$USER_C.csv
sudo rm $TEMP_PATH/$USER_B.csv
sudo rm $TEMP_PATH/$USER_C.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_ct.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$HOLD_KOD#;*#$HOLD_KOD#;#$HOLD_KOD#;" > $TEMP_PATH/$USER_A-hold.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$SS_KOD#;*#$SS_KOD#;#$SS_KOD#;" > $TEMP_PATH/$USER_A-ct.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_C;" > $TEMP_PATH/$USER_A-$USER_C.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;" > $TEMP_PATH/$USER_B.csv
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
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_ct.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_ct.txt          
  fi
}

# Registration users
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A-ct.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

COUNT=1
# Activate Hold, CT and check CT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_A-hold.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_A-ct.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_A-ct.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=2
# Test retreive after B diconnect
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr5_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_ctr4_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ch7.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error 
REZULT
sleep 2

COUNT=3
# Test consult: Call to C, flash, call to B, f2 (to C), f2 (to B). Bye A (CT C to B), Bye B
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr1_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ctr1.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 3 &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_ctr1_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=4
# Test consult: Call to C, flash, call to B, f1 (to C, reject current B), flash, call to B, f1 (to C, reject current B), flash, call to B. Bye A (CT C to B), Bye B  
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr2_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ctr2.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 3 &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr2_2_1.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr2_2_1.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_ctr2_2_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=5
# Test consult: Call to C, flash, call to B, f2 (to C), f0 (to C, reject held B), flash, call to B. Bye A (CT C to B), Bye B 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr2_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ctr3.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 3 &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr2_2_1.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_ctr2_2_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error 
REZULT
sleep 2

COUNT=6
######## Test normal CT before answer: Call to C, flash, call to B. Bye A (CT C to B), Bye B 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr4_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ctr4.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 3 &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_ctr4_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error  
REZULT
sleep 2

COUNT=7
######## Test normal CT after answer by digit 4: Call to C, flash, call to B, ans B. flash 4 (CT C to B), Bye B
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ch8_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ctr8.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 3 &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_ch8_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error 
REZULT
sleep 2

COUNT=8
######## Test normal CT to busy user
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr5_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/6-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ctr5.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=9
######## Test normal CT to unavailable user
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr5_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/7-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ctr7.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Deactivate 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_A-ct.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error  
REZULT

COUNT=10
######## Test service  CT not active. Bye transfer
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr5_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr6_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ctr6.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/3-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

######## Test service  CT not active. Flash 4 transfer
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ch8_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_ch8_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ch8.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

######## Test service 3way not active. Flash 3 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ch8_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_ch8_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ch8_1.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

######## Flash 5 when both users onheld
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ch8_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw_ch8_2.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ch8_2.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

# activate 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_A-ct.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error  
REZULT

# Unregistration
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT 

COUNT=11
######## Test normal CT to not reg
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw_ctr5_3.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw_ctr5n.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=12
# Deactivate 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_A-ct.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error      
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_A-hold.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

# Unregistration
COUNT=0
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A-ct.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-hold.csv
sudo rm $TEMP_PATH/$USER_A-ct.csv  
sudo rm $TEMP_PATH/$USER_A-$USER_C.csv
sudo rm $TEMP_PATH/$USER_B.csv
sudo rm $TEMP_PATH/$USER_C.csv

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

#!/bin/bash

# Тест BUGS. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента

# Переменные командной строки
# $1 SSW_IP_address
# $2 SIPP_IP_address

# Путь к скриптам
SRC_PATH=~/test/ssw_bug1
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
USER_A=200100
USER_B=500100
DOM_A=voip.local
DOM_B=$DOM_A
PORT_A=5060
PORT_B=5063

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_B.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_sswbug1.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;" > $TEMP_PATH/$USER_B.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_sswbug1.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_sswbug1.txt          
  fi
}

#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error

COUNT=$(($COUNT+1))
# Bug 47123. Unregister with other contact, transport missed
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth_bug47123.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
sleep 1
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0_bug47123.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 15

COUNT=$(($COUNT+1))
# Bug 46417. 408 after CANCEL ignored
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ssw_bug46417.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error -sleep 2 &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_ssw_bug46417.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error 
REZULT

COUNT=$(($COUNT+1))
# Bug 38464. Register w/ 2 authorization was rejected (in time it is answered)
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_bug38464.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=$(($COUNT+1))
# Bug 38162. Route in ACK. In this case ACK was ignored (in time ACK accepted)
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_ssw_bug38162.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ssw_bug38162.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=$(($COUNT+1))
# Bug 18967. Fake route in INVITE was ignored (in time INVITE rejected)
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ssw_bug18967.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ssw_bug18967_2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=$(($COUNT+1))
# Bug 36440. MSR has not rejected after hold/retrieve procedure had finished (in time MSR rejected)
# Конфигурируем 
$SRC_PATH/sswconf_hold.sh $3 $4 $5 $1 $USER_A
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_ssw_bug36440.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ssw_bug36440.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 

COUNT=$(($COUNT+1))
# No CdPN in INVITE. Answer 484.
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ssw_nocdpn.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=$(($COUNT+1))
# Bug. No SDP in 200 OK
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_nosdp_in200.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_nosdp_in200.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=$(($COUNT+1))
# Test timer H                                        
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_test_timer.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 

COUNT=$(($COUNT+1))
# No reregistration during the call. Registration of USER B finished during the call
# Конфигурируем необходимые таймеры
$SRC_PATH/sswconf_bug1.sh $3 $4 $5 $1
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth100.xml -inf $TEMP_PATH/$USER_B.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_norereg.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_norereg.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
# Конфигурируем необходимые таймеры
$SRC_PATH/sswconf_bug2.sh $3 $4 $5 $1
sleep 5

# Unregister user A                   
COUNT=0
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_B.csv

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

#!/bin/bash

# Тест SBC. Версия ПО 1.4.2.
# 
# Условия теста: создано одно направление

# Переменные командной строки
# $1 SBC_IP_address:port 1
# $2 SBC_IP_address:port 2
# $3 SIPP_IP_address
# $4 SIPP_PORT1
# $5 SIPP_PORT2

# Путь к скриптам
SRC_PATH=~/test/sbc/test1
TEMP_PATH=~/test/temp
AUDIO_PATH=../test/audio

# Путь к sipp
SIPP_PATH=~/sipp

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
USER_A=200100
USER_B=500100
DOM_A=voip.local

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_B-$USER_A.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_sbc1_tr.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv
echo "SEQUENTIAL;
$USER_B;$DOM_A;$USER_A;" > $TEMP_PATH/$USER_B-$USER_A.csv

# Переменные для подсчета успешных, неуспешных вызовов и номер теста
FAIL_COUNT=0
SUCC_COUNT=0

# Функция подсчета успешных и неуспешных вызовов
REZULT ()
{
  if test $? -ne 0
      then 
          FAIL_COUNT=$(($FAIL_COUNT+1))
          echo Test $COUNT failed >> $TEMP_PATH/results_sbc1_tr.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_sbc1_tr.txt          
  fi
}

## BASIC Calls
COUNT=2
# w/o 100rel
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_1xx.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_1xx_sdp.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_1xx.xml -mi $3 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_B-$USER_A.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error    
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_1xx.xml -mi $3 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_B-$USER_A.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error    
REZULT
sleep 2

# w/ 100 rel PRACK
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_prack.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_prack.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_prack2.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_prack2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_prack.xml -mi $3 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uac_prack.xml -inf $TEMP_PATH/$USER_B-$USER_A.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error    
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_prack2.xml -mi $3 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uac_prack2.xml -inf $TEMP_PATH/$USER_B-$USER_A.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error    
REZULT
sleep 2

# Modem
##sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_t38_play.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
##sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_t38_play.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
##REZULT
##sleep 2

COUNT=3
# Adaptation Nortell, different SDP in 1xx
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_1xx_diff_sdp.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_prack2_dif_sdp.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_prack2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

## Media
COUNT=4
# test codecs
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_g723_30_63a.xml -mi $3 -m 1 -nd -i $3 -p $5 -rtp_echo -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_g723_30_63_annexa_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A  -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_g726dyn.xml -mi $3 -m 1 -nd -i $3 -p $5 -rtp_echo -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_g726dyn_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_g729_80.xml -mi $3 -m 1 -nd -i $3 -p $5 -rtp_echo -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_g729_80_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_pcmu30.xml -mi $3 -m 1 -nd -i $3 -p $5 -rtp_echo -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_pcmu30_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A  -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_B-$USER_A.csv

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

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
# $6 SIPP_IP_address ssw side for nat

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
USER_NR=200101
DOM_A=voip.local

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_B-$USER_A.csv
sudo rm $TEMP_PATH/$USER_NR.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_sbc1_nat.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv
echo "SEQUENTIAL;
$USER_B;$DOM_A;$USER_A;" > $TEMP_PATH/$USER_B-$USER_A.csv
echo "SEQUENTIAL; 
$USER_NR;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_NR.csv
echo "SEQUENTIAL;
$USER_B;$DOM_A;$USER_NR;" > $TEMP_PATH/$USER_B-$USER_NR.csv

# Переменные для подсчета успешных, неуспешных вызовов и номер теста
FAIL_COUNT=0
SUCC_COUNT=0

# Функция подсчета успешных и неуспешных вызовов
REZULT ()
{
  if test $? -ne 0
      then 
          FAIL_COUNT=$(($FAIL_COUNT+1))
          echo Test $COUNT failed >> $TEMP_PATH/results_sbc1_nat.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_sbc1_nat.txt          
  fi
}


COUNT=1
## Registrations

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_0.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_all0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_0.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_all0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Adaptation SoftX 3000
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_wo_port.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_wo_port.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_0.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_all0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT 
sleep 2

## NAT enable
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_norport_via.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

## Different requests
COUNT=2
# OPTIONS
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/optans.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/opt.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/optans_in_dial.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/opt_in_dial.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# UPDATE
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_update_prack.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_update_prack.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Early UPDATE
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_update_bugearly.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_update_bugearly.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

## BASIC Calls
COUNT=3
# w/o 100rel
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_1xx.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_1xx_sdp.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_1xx.xml -mi $3 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_B-$USER_A.csv -mi $6 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error    
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_1xx_sdp.xml -mi $3 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_B-$USER_A.csv -mi $6 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error    
REZULT
sleep 2

# w/ 100 rel PRACK
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_prack.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_prack.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_prack2.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_prack2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_prack.xml -mi $3 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uac_prack.xml -inf $TEMP_PATH/$USER_B-$USER_A.csv -mi $6 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error    
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_prack2.xml -mi $3 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uac_prack2.xml -inf $TEMP_PATH/$USER_B-$USER_A.csv -mi $6 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error    
REZULT
sleep 2

# calls from/to not reg

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uac_ans404.xml -inf $TEMP_PATH/$USER_B-$USER_NR.csv -mi $6 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error
REZULT

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ans403.xml -inf $TEMP_PATH/$USER_NR.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uac_no_ans.xml -inf $TEMP_PATH/$USER_B-$USER_NR.csv -mi $7 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $7 -p $5 -recv_timeout 200s -timeout_error
REZULT

COUNT=4
## ROUTING
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_route.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_route_domain_480.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_rec_route_ip.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_bye.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_rec_route_5067_nat.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_rec_route_5067_2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

## Media
COUNT=5
# test codecs
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_g723_30_63a.xml -mi $6 -m 1 -nd -i $6 -p $5 -rtp_echo -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_g723_30_63_annexa_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_g726dyn.xml -mi $6 -m 1 -nd -i $6 -p $5 -rtp_echo -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_g726dyn_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_g729_80.xml -mi $6 -m 1 -nd -i $6 -p $5 -rtp_echo -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_g729_80_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_pcmu30.xml -mi $6 -m 1 -nd -i $6 -p $5 -rtp_echo -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_pcmu30_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# media control RTP, RTCP
# RTCP
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_sp_rtcp.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_sp_rtcp.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# RTCP control
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $6 -m 1 -nd -i $6 -p $5 -rtp_echo -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_sp_rtcp_timer.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=6
##Fail2ban
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_603.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ans603.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_603.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ans603.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error       
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_603.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ans603.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error       
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_403.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ans403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error       
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_403.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ans403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error       
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_403.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ans403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error       
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_403.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ans403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_0.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_403.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_403.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_403.xml -mi $6 -m 1 -nd -i $6 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

### FAIL2BAN will work only with REGISTER
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_no_ans.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_no_ans.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error 
REZULT

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_B-$USER_A.csv
sudo rm $TEMP_PATH/$USER_NR.csv 

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

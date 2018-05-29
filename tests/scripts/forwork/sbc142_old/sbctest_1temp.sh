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
sudo rm $TEMP_PATH/sbc_routing.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_sbc1.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv
echo "SEQUENTIAL;
$USER_B;$DOM_A;$USER_A;" > $TEMP_PATH/$USER_B-$USER_A.csv
echo "SEQUENTIAL;" > $TEMP_PATH/sbc_routing.csv

# Переменные для подсчета успешных, неуспешных вызовов и номер теста
FAIL_COUNT=0
SUCC_COUNT=0

# Функция подсчета успешных и неуспешных вызовов
REZULT ()
{
  if test $? -ne 0
      then 
          FAIL_COUNT=$(($FAIL_COUNT+1))
          echo Test $COUNT failed >> $TEMP_PATH/results_sbc1.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_sbc1.txt          
  fi
}

## Set DSCP for traffic
sudo iptables -t mangle -A OUTPUT -p udp -m udp --sport $4 -j DSCP --set-dscp-class cs3 # mark SIP UDP packets with CS3
sudo iptables -t mangle -A OUTPUT -p udp -m udp --sport 6000:8887 -j DSCP --set-dscp-class ef # mark RTP packets with EF

## Registrations

COUNT=1
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_bug_cont.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_0.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_all0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_100s.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_0.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_noexp.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_0.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_rport.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_0.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_401.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_401.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_403.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_401_bug100.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_401.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Adaptation SoftX 3000
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_wo_port.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_wo_port.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_407.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_407.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_503.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_503.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_0.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_all0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_all3600.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_mul_cont.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_0.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_all0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_mul_cont2.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_mul_cont2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans_0.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error & 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_all0.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error 
REZULT 
sleep 2

# NAT disable
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/regans.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_norport_via2_2.xml -mi $3 -m 1 -nd -i $3 -p 5070 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_norport_via2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

## Different requests
COUNT=2
# OPTIONS
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/optans.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/opt.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/optans_in_dial.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/opt_in_dial.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# UPDATE
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_update_prack.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_update_prack.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Early UPDATE
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_update_bugearly.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_update_bugearly.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# SUBSCRIBE
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/subans_presence.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/sub_difcont_presence.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/subans_msumm.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/sub_difcont_msumm.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/subans_ua_profile.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/sub_difcont_ua_profile.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/subans_keepalive.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/sub_difcont_keepalive.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

## BASIC Calls
COUNT=3
# w/o 100rel
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_1xx.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_1xx_sdp.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_plus_resh.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_plus_resh.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Anonymous
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_anonym.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_anonym_name.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# w/o 1xx
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_wo_1xx.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Cancel
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_cancel.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_cancel.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_bug_cancel_after_answer.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_bug_cancel_after_answer_no_to_tag.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# short
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_short.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=4
# w/ 100 rel PRACK
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_prack.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_prack.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_prack2.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_prack2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_prack_fake_bug.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_prack.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_prack_bugappl.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# other port in contact
#sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_portcont_part1.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_prack_receivebye.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error &
#sleep 2
#sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_portcont_part2_pj.xml -inf $TEMP_PATH/sbc_routing.csv -mi $3 -m 1 -nd -i $3 -p 5070 -recv_timeout 200s -timeout_error
#REZULT
#sleep 4

COUNT=5
# delay offer
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_delayoffer.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_183_sdp.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_delayoffer.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_delayoffer_prack.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_delayoffer_prack.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_delayoffer_prack2.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_delayoffer_prack2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_delayoffer_wreinvite.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_delayoffer_wreinvite.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# 4xx, 5xx
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_401.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ans403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_481.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ans481_on_bye.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_503.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ans503.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# no ACK
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_noack.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_noack.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2
# early reInvite
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_tout5.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_reinv_bug.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=6
## ROUTING
#sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_route.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
#REZULT
#sleep 2

#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_route_domain_480.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
#REZULT
#sleep 2

#sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_rec_route.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
#REZULT
#sleep 2

#sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_rec_route.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_rec_route.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
#REZULT
#sleep 2

#sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_rec_route2.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_rec_route.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
#REZULT
#sleep 2

#sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_rec_route_ip.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
#REZULT
#sleep 2

#sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_rec_route_5067.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
#sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_rec_route_5067_2.xml -mi $3 -m 1 -nd -i $3 -p 5067 -recv_timeout 200s -timeout_error &
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_pause_ack.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
#REZULT
#sleep 2

#sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_bye.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_rec_route_5067.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error &
#sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_rec_route_5067_2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p 5067 -recv_timeout 200s -timeout_error
#REZULT
#sleep 2

COUNT=7
## Test SDP
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_nomap.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_nomap.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_dynmap.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_dynmap.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_g729a_cisco.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_sdp_cisco729a.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Video
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_video.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_video.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Inactive
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_t38_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_t38.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_audio_t38.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_inact.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_video.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_inact.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_inact.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# 2 media w/ equal ptype
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_2media_bugsdp.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_sdp_twomedia_eq_pt.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
#sleep 2

# sendonly, receiveonly
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_ro.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_so.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_so.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ro.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=8
# errors in SDP
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_488.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_errorcodec.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_sdpbug2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_sdpbug3.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_sdpbug4.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_nortell.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# reduce media
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_red.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_red.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# modem
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_gpmd.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# rfc 2833 errors
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_2833_fmtpbug.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_sdp_rfc2833_empty_fmtp.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_2833_fmtpbug2.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_sdp_rfc2833_wo_fmtp.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# different SDP in 1xx
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_1xx_diff_sdp.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Adaptation nortell off
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_prack3_dif_sdp.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_prack3.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2 

## Media
COUNT=10
# test codecs
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_g723_30_63a.xml -mi $3 -m 1 -nd -i $3 -p $5 -rtp_echo -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_g723_30_63_annexa_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
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
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_pcmu30_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

## DTMF-FEATURES
# convert RFC - INFO
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_rfc2833_pt96.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_rfc2833_pt96.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_rfc2833_pt96_2.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_rfc2833_pt96_2.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# translate DTMF
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_rfc2833_pt96_dtmf.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_rfc2833_pt96_dtmf.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

## Sup SERVICES
COUNT=10
# 3xx
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p 5070 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_305.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_181m.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_ss_hold.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ss_hold.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_ss_hold_0000.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_ss_hold.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# ct not finished
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_refer_wonotify.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_refer_wonotify.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# diversion
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_div_3times_sip.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_div_3times_tel.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# Adaptation huawei
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_rcv_info.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_sbc_huawei.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

# adaptation si3000
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_1xx.xml -mi $3 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uac_user_phone.xml -inf $TEMP_PATH/$USER_B-$USER_A.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error 
REZULT
sleep 2

# translate DTMF
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_sbc_info_dtmf.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_sbc_info_dtmf.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 200s -timeout_error
REZULT
sleep 2

COUNT=11
## TIMERS
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_tC.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 600s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_tC.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 600s -timeout_error
REZULT
sleep 2

# timer RFC4028
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_timer_tranzsbc_uas.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 600s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_timer_tranzsbc_uas.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 600s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_timer_tranzsbc_uac.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 600s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_timer_tranzsbc_uac.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 600s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_timer_update.xml -mi $3 -m 1 -nd -i $3 -p $5 -recv_timeout 600s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_timer_update.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $3 -p $4 -recv_timeout 600s -timeout_error
REZULT
sleep 2

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_B-$USER_A.csv
sudo rm $TEMP_PATH/sbc_routing.csv

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

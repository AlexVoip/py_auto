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
# $6 limit
# $7 rate

# Путь к скриптам
SRC_PATH=~/test/sbc/test3
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

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv

# Modem
sudo $SIPP_PATH/sipp $2 -sf $SRC_PATH/uas_pcmu30.xml -mi $3 -m $6 -nd -i $3 -p $5 &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_pcmu30_audio.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $3 -s $USER_A -ap $USER_A -rtp_echo -l $6 -r $7 -m $6 -nd -i $3 -p $4 

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv

#!/bin/bash

# redirection test. Feature 42278 Версия ПО 3.3.
#
# Условия теста: создано два SIP-абонента и один SIP-транк

# Переменные командной строки
# $1 SSW_IP_address
# $2 SIPP_IP_address
# $3 SIPP port
# $4 num A
# $5 num B

# Путь к скриптам
SRC_PATH=~/test/ssw_grand
TEMP_PATH=~/test/temp
LOG_PATH=~/test/log

# Путь к sipp
SIPP_PATH=~/sipp

# Конфигурируем необходимые таймеры
#$SRC_PATH/sswconf_basic1.sh $1 $2 $3 $4

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
# Number C - SIP trunk user
USER_A=$4
USER_B=$5
PORT_A=$3
DOM_A=voip.local
SSWIP=$1
SIPPIP=$2

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_sswgrand.txt

echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_sswgrand.txt
      else
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_sswgrand.txt
  fi
}

# Тест

COUNT=1
sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uac_ssw_sdpprack.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $SIPPIP -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPPIP -p $PORT_A -recv_timeout 200s -timeout_error
REZULT


# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv

# Возвращаем исходные значения некоторым таймерам
#$SRC_PATH/sswconf_basic2.sh $1 $2 $3 $4

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

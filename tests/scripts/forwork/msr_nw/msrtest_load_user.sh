#!/bin/bash

# Тест нагрузки на абонентах. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента 

# Переменные командной строки
# $1 SSW_cocon_user
# $2 SSW_cocon_password
# $3 SSW_domain
# $4 SSW_IP_address
# $5 SIPP_IP_address
# $6 Call limit
# $7 Call rate

# Путь к скриптам
SRC_PATH=~/test/load_user
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
# Number C - SIP trunk user
USER_A=200100
DOM_A=voip.local
PORT_A=5060
USER_B=A000

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_loadusermsr.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_loadusermsr.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_loadusermsr.txt          
  fi
}

# Тест
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l $3 -r $4 -m $3 -nd -i $2 -p $PORT_A
REZULT

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A.csv

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi
#!/bin/bash

# Тест услуги Callback. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента

# Переменные командной строки
# $1 SSW_cocon_user
# $2 SSW_cocon_password
# $3 SSW_domain
# $4 SSW_IP_address
# $5 SIPP_IP_address
# $6 USER_A

# Путь к скриптам
SRC_PATH=~/test/ss_cb
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
USER_A=$6
USER_B=500100
DOM_A=voip.local
DOM_B=$DOM_A
PORT_A=5060
PORT_B=5063
KOD_CB=40


# Конфигурируем необходимые таймеры 
$SRC_PATH/sswconf_cb1.sh $1 $2 $3 $4 $USER_A

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A.csv
sudo rm $TEMP_PATH/$USER_B.csv
sudo rm $TEMP_PATH/$USER_A-cb.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_cb.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;" > $TEMP_PATH/$USER_A.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;" > $TEMP_PATH/$USER_B.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$KOD_CB#;" > $TEMP_PATH/$USER_A-cb.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_cb.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_cb.txt          
  fi
}

# Тест
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

# correct dial
	COUNT=1
	sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uac_487.xml -inf $TEMP_PATH/$USER_A-cb.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
	REZULT
	sleep 2
	
        sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/3-uas_ssw.xml -mi $5 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error &
	sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ssw_cb500100_1.xml -mi $5 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
	REZULT
	sleep 5

# incorrect dial
        COUNT=2
        sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uac_487.xml -inf $TEMP_PATH/$USER_A-cb.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error            
        REZULT
        sleep 2
                                        
        sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/uas_ssw_cb500100.xml -mi $5 -s $USER_A -ap $USER_A -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
        REZULT

COUNT=0
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A.csv -mi $5 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $4 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B.csv -mi $5 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $5 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT	

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A.csv
sudo rm $TEMP_PATH/$USER_B.csv
sudo rm $TEMP_PATH/$USER_A-cb.csv 

# Возвращаем исходные значения некоторым таймерам
$SRC_PATH/sswconf_cb2.sh $1 $2 $3 $4 $USER_A

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

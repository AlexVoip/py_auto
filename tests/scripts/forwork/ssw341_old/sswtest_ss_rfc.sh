#!/bin/bash

# Тест услуги RFC. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента

# Переменные командной строки
# $1 SSW_IP_address
# $2 SIPP_IP_address

# Путь к скриптам
SRC_PATH=~/test/ss_rfc
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
USER_A=200100
USER_B=500100
USER_C=800100
USER_D=200111
DOM_A=voip.local
DOM_B=$DOM_A
DOM_C=$1
DOM_D=voip.local
PORT_A=5060
PORT_B=5063
PORT_C=6060
PORT_D=5160
KOD_SS=64
KOD_CFU=21

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A.csv
sudo rm $TEMP_PATH/$USER_B-ss.csv
sudo rm $TEMP_PATH/$USER_D.csv
sudo rm $TEMP_PATH/$USER_C-$USER_B.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_rfc.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_D;" > $TEMP_PATH/$USER_A.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;*$KOD_SS#;*#$KOD_SS#;#$KOD_SS#;" > $TEMP_PATH/$USER_B-ss.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;$USER_B" > $TEMP_PATH/$USER_C-$USER_B.csv
echo "SEQUENTIAL;
$USER_D;$DOM_D;*$KOD_CFU*$USER_B#;*#$KOD_CFU#;#$KOD_CFU#;" > $TEMP_PATH/$USER_D.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_rfc.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_rfc.txt          
  fi
}

# Reg
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B-ss.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_D.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error
REZULT

COUNT=1
# Activate RFC and check
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_B-ss.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_B-ss.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

COUNT=2
## Activate CFU on USER_forward
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_D.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error
REZULT

# Check reject on forwarded calls                                        
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 
sleep 2

## Dectivate CFU on USER_forward
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_D.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error    
REZULT

COUNT=3
# Check reject on forwarded calls                                        
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403_rfc1.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error       
REZULT                       
sleep 2                      

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403_rfc2.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error  
REZULT
sleep 2

# Deactivate RFC 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_B-ss.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
                                    
COUNT=4
# Check answer on forwarded calls                                        
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_rfc1.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error
REZULT                       
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_rfc2.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error
REZULT
sleep 2
                   
COUNT=0
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B-ss.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT	
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_D.csv -mi $2 -s $USER_D -ap $USER_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_D -recv_timeout 200s -timeout_error 
REZULT

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A.csv
sudo rm $TEMP_PATH/$USER_B-ss.csv
sudo rm $TEMP_PATH/$USER_D.csv
sudo rm $TEMP_PATH/$USER_C-$USER_B.csv

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

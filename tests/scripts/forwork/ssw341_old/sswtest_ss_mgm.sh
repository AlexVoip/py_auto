#!/bin/bash

# Тест услуги "Отмена всех услуг" - MGM. Версия ПО 3.3.
# 
# Условия теста: активированы услуги (выполнен скрипт sswconf_ss_perm.sh)

# Переменные командной строки
# $1 SSW_IP_address
# $2 SIPP_IP_address

# Путь к скриптам
SRC_PATH=~/test/ss_mgm
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
USER_MASS=("200100" "500100" "200110" "200111" "200112" "200113" "200114" "200115" "200116" "200117" "200118")
USER_DOM_MASS=("voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local")
USER_PIN_MASS=("1111" "1111" "1111" "1111" "1111" "1111" "1111" "1111" "1111" "1111" "1111")
PORT_MASS=("5060" "5060" "5060" "5060" "5060" "5060" "5060" "5060" "5060" "5060" "5060")
MGM_KOD=50

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_mgm.txt

# Переменные для подсчета успешных, неуспешных вызовов и номер теста
FAIL_COUNT=0
SUCC_COUNT=0

# Функция подсчета успешных и неуспешных вызовов
REZULT ()
{
  if test $? -ne 0
      then 
          FAIL_COUNT=$(($FAIL_COUNT+1))
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_mgm.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_mgm.txt          
  fi
}

# Удаляем файлы с данными (на случай, если они не были удалены)
for (( COUNT=0; COUNT<${#PORT_MASS[*]}; COUNT++ ));
do
sudo rm $TEMP_PATH/${USER_MASS[$COUNT]}.csv
done

for (( COUNT=0; COUNT<${#PORT_MASS[*]}; COUNT++ ));
do
# Создаем файлы с данными
echo "SEQUENTIAL;
${USER_MASS[$COUNT]};${USER_DOM_MASS[$COUNT]};#$MGM_KOD*${USER_PIN_MASS[$COUNT]}#;" > $TEMP_PATH/${USER_MASS[$COUNT]}.csv

# Registration users
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/${USER_MASS[$COUNT]}.csv -mi $2 -s ${USER_MASS[$COUNT]} -ap ${USER_MASS[$COUNT]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error
REZULT

# Deactivation feature
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/${USER_MASS[$COUNT]}.csv -mi $2 -s ${USER_MASS[$COUNT]} -ap ${USER_MASS[$COUNT]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error
REZULT

# Deregistration users
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/${USER_MASS[$COUNT]}.csv -mi $2 -s ${USER_MASS[$COUNT]} -ap ${USER_MASS[$COUNT]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error
REZULT

done

# Удаляем файлы с данными
for (( COUNT=0; COUNT<${#PORT_MASS[*]}; COUNT++ ));
do
sudo rm $TEMP_PATH/${USER_MASS[$COUNT]}.csv                             
done

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

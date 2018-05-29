#!/bin/bash

# Тест услуги "Белый список" - SCA, SCO_white. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента и один SIP-транк
#              : активированы услуги (выполнен скрипт sswconf_ss_perm.sh)

# Переменные командной строки
# $1 SSW_IP_address
# $2 SIPP_IP_address

# Путь к скриптам
SRC_PATH=~/test/ss_sca_sco
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
# Number C and D - SIP trunk user
USER_A=200100
USER_A_NC=20010
USER_B=500100
USER_B_NC=50010
USER_C=800100
USER_C_MF=400100
USER_D=$(($USER_C+1))
DOM_A=voip.local
DOM_B=voip.local
DOM_C=$1
PORT_A=5060
PORT_B=5063
PORT_C=6060
SCA_KOD=60
SCR_KOD=61
SCO_WH_KOD=62
SCO_BL_KOD=63
PIN_A=1111
PIN_B=1111

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A-scasco.csv
sudo rm $TEMP_PATH/$USER_B-scasco.csv
sudo rm $TEMP_PATH/$USER_A-scrsco.csv 
sudo rm $TEMP_PATH/$USER_B-scrsco.csv 
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_A-$USER_C.csv
sudo rm $TEMP_PATH/$USER_B-$USER_A.csv
sudo rm $TEMP_PATH/$USER_B-$USER_C.csv
sudo rm $TEMP_PATH/$USER_C-$USER_A.csv
sudo rm $TEMP_PATH/$USER_C-$USER_B.csv
sudo rm $TEMP_PATH/$USER_D-$USER_B.csv

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_scasco.txt

# Создаем файлы с данными
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$SCO_WH_KOD*$PIN_A#;#$SCO_WH_KOD*$PIN_A#;*$SCO_WH_KOD*$PIN_A*0*$USER_B_NC#;*$SCO_WH_KOD*$PIN_A*1*$USER_B_NC#;*$SCO_WH_KOD*$PIN_A*$USER_B#;#$SCO_WH_KOD*$PIN_A*0#;#$SCO_WH_KOD*$PIN_A*1#;#$SCO_WH_KOD*$PIN_A*$USER_B#;*$SCO_WH_KOD*$PIN_A*2*$USER_C_MF#;#$SCO_WH_KOD*$PIN_A*$USER_C_MF#;" > $TEMP_PATH/$USER_A-scasco.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;*$SCO_BL_KOD*$PIN_A#;#$SCO_BL_KOD*$PIN_A#;" > $TEMP_PATH/$USER_A-scrsco.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;*$SCA_KOD*$PIN_B#;#$SCA_KOD*$PIN_B#;*$SCA_KOD*$PIN_B*0*$USER_A_NC#;*$SCA_KOD*$PIN_B*1*$USER_A_NC#;*$SCA_KOD*$PIN_B*$USER_A#;#$SCA_KOD*$PIN_B*0#;#$SCA_KOD*$PIN_B*1#;#$SCA_KOD*$PIN_B*$USER_A#;*$SCA_KOD*$PIN_B*2*$USER_C#;#$SCA_KOD*$PIN_B*$USER_C#;" > $TEMP_PATH/$USER_B-scasco.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;*$SCR_KOD*$PIN_B#;#$SCR_KOD*$PIN_B#;*$SCR_KOD*$PIN_B*1*$USER_A_NC#;#$SCR_KOD*$PIN_B*0#;" > $TEMP_PATH/$USER_B-scrsco.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv
echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_C;" > $TEMP_PATH/$USER_A-$USER_C.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;$USER_A;" > $TEMP_PATH/$USER_B-$USER_A.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;$USER_C;" > $TEMP_PATH/$USER_B-$USER_C.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;$USER_A;" > $TEMP_PATH/$USER_C-$USER_A.csv
echo "SEQUENTIAL;
$USER_C;$DOM_C;$USER_B;" > $TEMP_PATH/$USER_C-$USER_B.csv
echo "SEQUENTIAL;
$USER_D;$DOM_C;$USER_B;" > $TEMP_PATH/$USER_D-$USER_B.csv

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
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_scasco.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_scasco.txt          
  fi
}

# Registration users
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

# Control of deactivation of SCA and SCO features
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error 
REZULT

# Activation of SCO_WH and SCO_BL features to user A (WH will be work with prio)
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT


# Control extraction of user B  and user C numbers from white list
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field11.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

# Test SCO_WHITE
COUNT=1
# No numbers in list, all calls rejected
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=2
# Add num in 0 string in list. Must be error
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
# Add num user_B_not_compl, user_C_modify in list and test
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field5.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT  
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field10.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT  
# Calls
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error      
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
# delete USER_C_MF and USER_B_NC from list
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field11.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field7.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 
# Call to USER_B
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 3

COUNT=3
# Add num user_B_not_compl in list and test
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field5.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT  
# Calls 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
# delete USER_B_NC from list
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field8.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 
# Call to USER_B
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 3

COUNT=4
# Add num user_B_not_compl in list and test
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field6.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT  
# Calls 
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
# delete USER_B_NC from list
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 
# Call to USER_B
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 3

COUNT=5
# Deactivation of SCA and SCO features
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_A-scrsco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT 
# Calls to USER_B and USER_C, success
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_C.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

# Test SCA
COUNT=6
# Activation of SCA and SCR features to user B (WH will be work with prio)
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

# Control extraction of user A and user C numbers from white list
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field11.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

# Call to USER_B
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=7
# Add num in 0 string in list. Must be error
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Add num user A not compl in white and black list. Prio White
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field5.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B, success A, fail C
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error
REZULT
sleep 3
# Extract number of user A from white, black list and deactivate SCR
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field5.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_B-scrsco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field7.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=8
# Add num user A in white list
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field5.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B, success, fail C
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error
REZULT
sleep 3
# Extract number of user A from white list
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field8.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=9
# Add num user A in white list
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field6.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B, success, fail C
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error
REZULT
sleep 3
# Extract number of user A from white list                          
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field9.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_403.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

COUNT=10
# Add num user C modify in white list
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field10.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B, success
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_D-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error
REZULT
sleep 3
# Extract number of user C from white list                          
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field11.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT

COUNT=11
# Deactivation of SCA feature
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT
# Call to USER_B, success
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_C-$USER_B.csv -mi $2 -s $USER_C -ap $USER_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_C -recv_timeout 200s -timeout_error
REZULT
sleep 3
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT

# Unregistration
COUNT=0
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_A-scasco.csv -mi $2 -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/$USER_B-scasco.csv -mi $2 -s $USER_B -ap $USER_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p $PORT_B -recv_timeout 200s -timeout_error
REZULT	

# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-scasco.csv
sudo rm $TEMP_PATH/$USER_B-scasco.csv
sudo rm $TEMP_PATH/$USER_A-scrsco.csv
sudo rm $TEMP_PATH/$USER_B-scrsco.csv
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_A-$USER_C.csv
sudo rm $TEMP_PATH/$USER_B-$USER_A.csv
sudo rm $TEMP_PATH/$USER_B-$USER_C.csv
sudo rm $TEMP_PATH/$USER_C-$USER_A.csv
sudo rm $TEMP_PATH/$USER_C-$USER_B.csv
sudo rm $TEMP_PATH/$USER_D-$USER_B.csv

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

#!/bin/bash

# Тест услуги "Переадресация безусловная по времени" - CFT. Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента и один SIP транк
#              : активированы услуги (выполнен скрипт sswconf_ss_perm.sh)

# Переменные командной строки
# $1 SSW_IP_address
# $2 SIPP_IP_address
# $3 Признак дня выполнения теста (0 - будние, other - выходные)

# Путь к скриптам
SRC_PATH=~/test/ss_cfu
TEMP_PATH=~/test/temp

# Путь к sipp
SIPP_PATH=~/sipp

# Номера абонентов
# Number 8 - SIP user
# Number 4  - SIP dynamic user
# Number 12 - SIP trunk user
USER_MASS=("200110" "200111" "200112" "500100" "200113" "200114" "200115" "200100" "200116" "200117" "200118" "800100")
USER_DOM_MASS=("voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "voip.local" "$1")
PORT_MASS=("5060" "5160" "5060" "5063" "5060" "5060" "5060" "5060" "5060" "5060" "5060" "6060")
CFU_KOD=28
PRIZNAK=$3
# Not registered, Unallocated, No such number
USER_NR=200101
USER_UA=200102
USER_NN=2000000

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_ss_cft.txt

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
          echo Test $COUNT failed >> $TEMP_PATH/results_ss_cft.txt
      else 
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_ss_cft.txt          
  fi
}

# Функция исключениянескольких элементов
IGNORE ()
{
if test $COUNT -eq 3
   then
     COUNT=$(($COUNT+1))
fi                  
if test $COUNT -eq 7
   then
     COUNT=$(($COUNT+1))
fi    
}

# Удаляем файлы с данными (на случай, если они не были удалены)
for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
do
sudo rm $TEMP_PATH/${USER_MASS[$COUNT]}.csv
sudo rm $TEMP_PATH/${USER_MASS[$COUNT]}-2.csv
done

sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[0]}.csv
sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[1]}.csv
sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[2]}.csv
sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[8]}.csv
sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[9]}.csv
sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[10]}.csv
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[0]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[1]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[2]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[4]}.csv
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[5]}.csv
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[6]}.csv
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[8]}.csv
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[9]}.csv
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[10]}.csv
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[0]}.csv
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[1]}.csv
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[2]}.csv
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[4]}.csv
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[5]}.csv
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[6]}.csv
sudo rm $TEMP_PATH/${USER_MASS[10]}-max.csv
sudo rm $TEMP_PATH/${USER_MASS[0]}-$USER_NR.csv
sudo rm $TEMP_PATH/${USER_MASS[1]}-$USER_UA.csv
sudo rm $TEMP_PATH/${USER_MASS[2]}-$USER_NN.csv


if test $PRIZNAK -eq 0
   then {
for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
do 
# Создаем файлы с данными
echo "SEQUENTIAL;
${USER_MASS[$COUNT]};${USER_DOM_MASS[$COUNT]};*$CFU_KOD*12345*00012359*${USER_MASS[$(($COUNT+1))]}#;*#$CFU_KOD#;#$CFU_KOD#;*$CFU_KOD#;" > $TEMP_PATH/${USER_MASS[$COUNT]}.csv
echo "SEQUENTIAL;
${USER_MASS[$COUNT]};${USER_DOM_MASS[$COUNT]};*$CFU_KOD*67*00012359*${USER_MASS[$(($COUNT+1))]}#;*#$CFU_KOD*3#;#$CFU_KOD*12345#;" > $TEMP_PATH/${USER_MASS[$COUNT]}-2.csv
done
}
else {
   for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
   do 
   # Создаем файлы с данными
   echo "SEQUENTIAL;
   ${USER_MASS[$COUNT]};${USER_DOM_MASS[$COUNT]};*$CFU_KOD*67*00012359*${USER_MASS[$(($COUNT+1))]}#;*#$CFU_KOD#;#$CFU_KOD#;*$CFU_KOD#;" > $TEMP_PATH/${USER_MASS[$COUNT]}.csv
   echo "SEQUENTIAL;
   ${USER_MASS[$COUNT]};${USER_DOM_MASS[$COUNT]};*$CFU_KOD*12345*00012359*${USER_MASS[$(($COUNT+1))]}#;*#$CFU_KOD*6#;#$CFU_KOD*67#;" > $TEMP_PATH/${USER_MASS[$COUNT]}-2.csv     
   done
   }
fi

# Создаем файлы с данными
echo "SEQUENTIAL;
${USER_MASS[7]};${USER_DOM_MASS[7]};${USER_MASS[0]};" > $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[0]}.csv
echo "SEQUENTIAL;
${USER_MASS[7]};${USER_DOM_MASS[7]};${USER_MASS[1]};" > $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[1]}.csv  
echo "SEQUENTIAL;
${USER_MASS[7]};${USER_DOM_MASS[7]};${USER_MASS[2]};" > $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[2]}.csv  
echo "SEQUENTIAL;
${USER_MASS[7]};${USER_DOM_MASS[7]};${USER_MASS[8]};" > $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[8]}.csv  
echo "SEQUENTIAL;
${USER_MASS[7]};${USER_DOM_MASS[7]};${USER_MASS[9]};" > $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[9]}.csv  
echo "SEQUENTIAL;
${USER_MASS[7]};${USER_DOM_MASS[7]};${USER_MASS[10]};" > $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[10]}.csv  

echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[3]};${USER_MASS[0]};" > $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[0]}.csv  
echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[3]};${USER_MASS[1]};" > $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[1]}.csv
echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[3]};${USER_MASS[2]};" > $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[2]}.csv
echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[3]};${USER_MASS[4]};" > $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[4]}.csv  
echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[3]};${USER_MASS[5]};" > $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[5]}.csv 
echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[3]};${USER_MASS[6]};" > $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[6]}.csv 
echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[3]};${USER_MASS[8]};" > $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[8]}.csv 
echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[3]};${USER_MASS[9]};" > $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[9]}.csv 
echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[3]};${USER_MASS[10]};" > $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[10]}.csv 

echo "SEQUENTIAL;
${USER_MASS[7]};${USER_DOM_MASS[11]};${USER_MASS[0]};" > $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[0]}.csv
echo "SEQUENTIAL;
${USER_MASS[7]};${USER_DOM_MASS[11]};${USER_MASS[1]};" > $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[1]}.csv
echo "SEQUENTIAL;
${USER_MASS[7]};${USER_DOM_MASS[11]};${USER_MASS[2]};" > $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[2]}.csv
echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[11]};${USER_MASS[4]};" > $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[4]}.csv
echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[11]};${USER_MASS[5]};" > $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[5]}.csv
echo "SEQUENTIAL;
${USER_MASS[3]};${USER_DOM_MASS[11]};${USER_MASS[6]};" > $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[6]}.csv

if test $PRIZNAK -eq 0
   then {
echo "SEQUENTIAL;
${USER_MASS[10]};${USER_DOM_MASS[10]};*$CFU_KOD*12345*00012359*${USER_MASS[0]}#;" > $TEMP_PATH/${USER_MASS[10]}-max.csv
echo "SEQUENTIAL;
${USER_MASS[0]};${USER_DOM_MASS[0]};*$CFU_KOD*12345*00012359*$USER_NR#;" > $TEMP_PATH/${USER_MASS[0]}-$USER_NR.csv
echo "SEQUENTIAL;
${USER_MASS[1]};${USER_DOM_MASS[1]};*$CFU_KOD*12345*00012359*$USER_UA#;" > $TEMP_PATH/${USER_MASS[1]}-$USER_UA.csv 
echo "SEQUENTIAL;
${USER_MASS[2]};${USER_DOM_MASS[2]};*$CFU_KOD*12345*00012359*$USER_NN#;" > $TEMP_PATH/${USER_MASS[2]}-$USER_NN.csv 
}
else {
echo "SEQUENTIAL;
${USER_MASS[10]};${USER_DOM_MASS[10]};*$CFU_KOD*67*00012359*${USER_MASS[0]}#;" > $TEMP_PATH/${USER_MASS[10]}-max.csv
echo "SEQUENTIAL;
${USER_MASS[0]};${USER_DOM_MASS[0]};*$CFU_KOD*67*00012359*$USER_NR#;" > $TEMP_PATH/${USER_MASS[0]}-$USER_NR.csv
echo "SEQUENTIAL;
${USER_MASS[1]};${USER_DOM_MASS[1]};*$CFU_KOD*67*00012359*$USER_UA#;" > $TEMP_PATH/${USER_MASS[1]}-$USER_UA.csv
echo "SEQUENTIAL;
${USER_MASS[2]};${USER_DOM_MASS[2]};*$CFU_KOD*67*00012359*$USER_NN#;" > $TEMP_PATH/${USER_MASS[2]}-$USER_NN.csv
}
fi

for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
do
# Registration users
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/${USER_MASS[$COUNT]}.csv -mi $2 -s ${USER_MASS[$COUNT]} -ap ${USER_MASS[$COUNT]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error
REZULT
done

for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
do
IGNORE
# Activation feature
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/${USER_MASS[$COUNT]}.csv -mi $2 -s ${USER_MASS[$COUNT]} -ap ${USER_MASS[$COUNT]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error
REZULT
done

for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
do
IGNORE
# Control feature started at defined day
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/${USER_MASS[$COUNT]}-2.csv -mi $2 -s ${USER_MASS[$COUNT]} -ap ${USER_MASS[$COUNT]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error
REZULT
done

# CFU once and with PRACK
COUNT=0
while [ $COUNT -lt 3 ] 
do
COUNT=$(($COUNT+1))

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[2]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[10]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[6]}.csv -mi $2 -s ${USER_MASS[3]} -ap ${USER_MASS[3]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[10]}.csv -mi $2 -s ${USER_MASS[3]} -ap ${USER_MASS[3]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[2]}.csv -mi $2 -s ${USER_MASS[11]} -ap ${USER_MASS[11]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[6]}.csv -mi $2 -s ${USER_MASS[11]} -ap ${USER_MASS[11]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

done

#CFU twice
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[1]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[9]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[5]}.csv -mi $2 -s ${USER_MASS[3]} -ap ${USER_MASS[3]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[9]}.csv -mi $2 -s ${USER_MASS[3]} -ap ${USER_MASS[3]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[1]}.csv -mi $2 -s ${USER_MASS[11]} -ap ${USER_MASS[11]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[5]}.csv -mi $2 -s ${USER_MASS[11]} -ap ${USER_MASS[11]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

#CFU three
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[0]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[8]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[4]}.csv -mi $2 -s ${USER_MASS[3]} -ap ${USER_MASS[3]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[8]}.csv -mi $2 -s ${USER_MASS[3]} -ap ${USER_MASS[3]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[0]}.csv -mi $2 -s ${USER_MASS[11]} -ap ${USER_MASS[11]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[4]}.csv -mi $2 -s ${USER_MASS[11]} -ap ${USER_MASS[11]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

# To busy, to unavailable
COUNT=5
while [ $COUNT -lt 7 ]
do
COUNT=$(($COUNT+1))

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[0]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[8]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[4]}.csv -mi $2 -s ${USER_MASS[3]} -ap ${USER_MASS[3]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[8]}.csv -mi $2 -s ${USER_MASS[3]} -ap ${USER_MASS[3]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[0]}.csv -mi $2 -s ${USER_MASS[11]} -ap ${USER_MASS[11]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/$COUNT-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[4]}.csv -mi $2 -s ${USER_MASS[11]} -ap ${USER_MASS[11]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

done

# Max redirect=5
COUNT=8
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/${USER_MASS[10]}-max.csv -mi $2 -s ${USER_MASS[10]} -ap ${USER_MASS[10]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[10]} -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[9]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

########### W/ PRACK
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/2-uac_181_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[9]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT 
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2_483.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[8]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error   
REZULT
sleep 2

# Not register, Unallocated, No number
COUNT=9
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/${USER_MASS[0]}-$USER_NR.csv -mi $2 -s ${USER_MASS[0]} -ap ${USER_MASS[0]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[0]} -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/${USER_MASS[1]}-$USER_UA.csv -mi $2 -s ${USER_MASS[1]} -ap ${USER_MASS[1]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[1]} -recv_timeout 200s -timeout_error
REZULT
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/${USER_MASS[2]}-$USER_NN.csv -mi $2 -s ${USER_MASS[2]} -ap ${USER_MASS[2]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[2]} -recv_timeout 200s -timeout_error
REZULT

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/11-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[0]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT
sleep 2
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/11-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[0]}.csv -mi $2 -s ${USER_MASS[3]} -ap ${USER_MASS[3]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error
REZULT
sleep 2
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/11-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[0]}.csv -mi $2 -s ${USER_MASS[11]} -ap ${USER_MASS[11]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error    
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/12-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[1]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT
sleep 2
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/12-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[1]}.csv -mi $2 -s ${USER_MASS[3]} -ap ${USER_MASS[3]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error    
REZULT
sleep 2
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/12-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[1]}.csv -mi $2 -s ${USER_MASS[11]} -ap ${USER_MASS[11]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/13-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[2]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT
sleep 2
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/13-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[2]}.csv -mi $2 -s ${USER_MASS[3]} -ap ${USER_MASS[3]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[3]} -recv_timeout 200s -timeout_error    
REZULT
sleep 2
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/13-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[2]}.csv -mi $2 -s ${USER_MASS[11]} -ap ${USER_MASS[11]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[11]} -recv_timeout 200s -timeout_error
REZULT
sleep 2

for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
do
IGNORE
# Deactivation feature for activated days
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/${USER_MASS[$COUNT]}-2.csv -mi $2 -s ${USER_MASS[$COUNT]} -ap ${USER_MASS[$COUNT]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error
REZULT
done

for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
do
IGNORE
# Activation feature for works or holiday days
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field2.xml -inf $TEMP_PATH/${USER_MASS[$COUNT]}-2.csv -mi $2 -s ${USER_MASS[$COUNT]} -ap ${USER_MASS[$COUNT]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error
REZULT
done

for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
do
IGNORE
# Control feature
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field3.xml -inf $TEMP_PATH/${USER_MASS[$COUNT]}.csv -mi $2 -s ${USER_MASS[$COUNT]} -ap ${USER_MASS[$COUNT]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error
REZULT
done

# CFT doesnt work because not forwarding period occurs
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uas_ssw.xml -mi $2 -m 1 -nd -i $2 -p ${PORT_MASS[1]} -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/1-uac_ssw.xml -inf $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[1]}.csv -mi $2 -s ${USER_MASS[7]} -ap ${USER_MASS[7]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[7]} -recv_timeout 200s -timeout_error
REZULT
sleep 2


for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
do
IGNORE
# Deactivation feature
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/uac_field4.xml -inf $TEMP_PATH/${USER_MASS[$COUNT]}.csv -mi $2 -s ${USER_MASS[$COUNT]} -ap ${USER_MASS[$COUNT]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error
REZULT
done

# Unregistration
for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
do
sudo $SIPP_PATH/sipp $1 -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/${USER_MASS[$COUNT]}.csv -mi $2 -s ${USER_MASS[$COUNT]} -ap ${USER_MASS[$COUNT]} -rtp_echo -l 1 -r 1 -m 1 -nd -i $2 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error
REZULT
done  

# Удаляем файлы с данными (на случай, если они не были удалены)
for (( COUNT=0; COUNT<${#PORT_MASS[*]}-1; COUNT++ ));
do
sudo rm $TEMP_PATH/${USER_MASS[$COUNT]}.csv
sudo rm $TEMP_PATH/${USER_MASS[$COUNT]}-2.csv
done

# Удаляем файлы с данными
sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[0]}.csv                                                       
sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[1]}.csv                                                       
sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[2]}.csv                                                       
sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[8]}.csv                                                       
sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[9]}.csv                                                       
sudo rm $TEMP_PATH/${USER_MASS[7]}-${USER_MASS[10]}.csv
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[0]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[1]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[2]}.csv                                                       
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[4]}.csv                                                       
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[5]}.csv                                                       
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[6]}.csv                                                       
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[8]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[9]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[3]}-${USER_MASS[10]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[0]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[1]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[2]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[4]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[5]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[11]}-${USER_MASS[6]}.csv 
sudo rm $TEMP_PATH/${USER_MASS[10]}-max.csv 
sudo rm $TEMP_PATH/${USER_MASS[0]}-$USER_NR.csv 
sudo rm $TEMP_PATH/${USER_MASS[1]}-$USER_UA.csv 
sudo rm $TEMP_PATH/${USER_MASS[2]}-$USER_NN.csv

# Вывод результата  
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"	

  if test $FAIL_COUNT -ne 0
        then 
        exit 1
        else 
        exit 0
  fi

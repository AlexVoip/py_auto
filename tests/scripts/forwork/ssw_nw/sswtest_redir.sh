#!/bin/bash

# redirection test. Feature 42278 Версия ПО 3.3.
# 
# Условия теста: создано два SIP-абонента и один SIP-транк

# Переменные командной строки
# $1 SSW_IP_address
# $2 SIPP_IP_address
# $3 SIPP inc trunk port
# $4 SIPP term trunk port
# $5 SSW domain
# $6 num A
# $7 num B

# Путь к скриптам
SRC_PATH=~/test/sswredir
TEMP_PATH=~/test/temp
LOG_PATH=~/test/log
FUNC_PATH=~/test/func_lib

source $FUNC_PATH/isup_func_lib.sh

# Путь к sipp
SIPP_PATH=~/sipp

# Конфигурируем необходимые таймеры
#$SRC_PATH/sswconf_basic1.sh $1 $2 $3 $4

# Номера абонентов
# Number A - SIP user
# Number B - SIP dynamic user
# Number C - SIP trunk user
USER_A=$6
USER_B=$7
DOM_A=$5
DOM_B=$5
PORT_A=$3
PORT_B=$4
SSWIP=$1
SIPPIP=$2


NUM_CALLING=$USER_A
NUM_CALLED=$USER_B
NATURE_CALLING=3
NATURE_CALLED=3

NCI_ABCD=0000
NCI_EFGH=0000
FCI_ABCD_1=0000
FCI_EFGH_1=0110
FCI_ABCD_2=0000
FCI_EFGH_2=0000
CPC_2_IAM=1010
TMR_1=0000
TMR_2=0011

CPC_IJKL=1000
CPC_MNOP=0000

ORIG_RED=3
CUR_RED=2
COUNT_RED=2

NATURE_ORIGIN=3
NATURE_REDIR=3
NUM_REDIR=665000
NUM_ORIGIN=653001

NUM_GENERIC=640665
NATURE_GENERIC=3
QUALIFIER=1

# Удаляем файлы с данными (на случай, если они не были удалены)
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_B-$USER_A.csv

sudo rm $TEMP_PATH/isup_inj.csv
sudo rm $SRC_PATH/uac_isup_main.xml
sudo rm $SRC_PATH/uac_isup_main1.xml
sudo rm $SRC_PATH/uac_isup_main2.xml
sudo rm $SRC_PATH/uac_isup_main3.xml
sudo rm $SRC_PATH/uac_isup_main4.xml
sudo rm $SRC_PATH/uac_isup_main5.xml
sudo rm $SRC_PATH/uac_isup_main6.xml
sudo rm $SRC_PATH/uas_isup_main.xml

# Удаляем файл (необходим для поиска ошибки) с результатами по каждому тесту
sudo rm $TEMP_PATH/results_sswredir.txt

# Создаем файлы с данными

touch $TEMP_PATH/isup_inj.csv            # Создание инжекционного файла
touch $SRC_PATH/uac_isup_main.xml                       # Создание файла сценария uac
touch $SRC_PATH/uas_isup_main.xml                       # Создание файла сценария uas

echo "SEQUENTIAL;
$USER_A;$DOM_A;$USER_B;" > $TEMP_PATH/$USER_A-$USER_B.csv
echo "SEQUENTIAL;
$USER_B;$DOM_B;$USER_A;" > $TEMP_PATH/$USER_B-$USER_A.csv

echo "SEQUENTIAL" >> $TEMP_PATH/isup_inj.csv
echo "$NUM_CALLING;$NUM_CALLED;$NUM_REDIR;$NUM_ORIGIN;$COUNT_RED" >> $TEMP_PATH/isup_inj.csv


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
          echo Test $COUNT failed >> $TEMP_PATH/results_sswredir.txt
      else
          SUCC_COUNT=$(($SUCC_COUNT+1))
          echo Test $COUNT passed >> $TEMP_PATH/results_sswredir.txt
  fi
}

# Тест

COUNT=1
sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/red_uas_ssw.xml -mi $SIPPIP -m 1 -nd -i $SIPPIP -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/red_div_uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $SIPPIP -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPPIP -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 3

sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/red_uas_ssw.xml -mi $SIPPIP -m 1 -nd -i $SIPPIP -p $PORT_B -recv_timeout 200s -timeout_error &
sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/red_to_uac_ssw.xml -inf $TEMP_PATH/$USER_A-$USER_B.csv -mi $SIPPIP -s $USER_A -ap $USER_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPPIP -p $PORT_A -recv_timeout 200s -timeout_error
REZULT
sleep 3

COUNT=2
# redir, origin
# Формирование UAC

Full_seq_redir

cat $SRC_PATH/uac_isup_1.txt >> $SRC_PATH/uac_isup_main.xml
echo "$FULL_SEQ_REDIR" >> $SRC_PATH/uac_isup_main.xml
cat $SRC_PATH/uac_isup_2.txt >> $SRC_PATH/uac_isup_main.xml

# Формирование UAS

# Формирование полных последовательностей

CPC

full_uas_183='\x06\x12\x'$CPC_HEX'\x00'

full_uas_180='\x2c\x01\x01\x11\x02\x16\x'$CPC_HEX'\x00'

full_uas_200='\x09\x00'

# Заполнение файла сценария uas

cat $SRC_PATH/uas_isup_1.txt >> $SRC_PATH/uas_isup_main.xml
echo "$full_uas_183" >> $SRC_PATH/uas_isup_main.xml
cat $SRC_PATH/uas_isup_2.txt >> $SRC_PATH/uas_isup_main.xml
echo "$full_uas_180" >> $SRC_PATH/uas_isup_main.xml
cat $SRC_PATH/uas_isup_3.txt >> $SRC_PATH/uas_isup_main.xml
echo "$full_uas_200" >> $SRC_PATH/uas_isup_main.xml
cat $SRC_PATH/uas_isup_4.txt >> $SRC_PATH/uas_isup_main.xml

sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uas_isup_main.xml -recv_timeout 200s -timeout_error -s $NUM_CALLING -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_B &
sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uac_isup_main.xml -recv_timeout 200s -timeout_error -s $NUM_CALLED -inf $TEMP_PATH/isup_inj.csv -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_A
REZULT
sleep 3


COUNT=3
# Redir, origin, generic
# Формирование UAC

Full_seq_redir_generic

cat $SRC_PATH/uac_isup_1.txt >> $SRC_PATH/uac_isup_main1.xml
echo "$FULL_SEQ_REDIR_GENERIC" >> $SRC_PATH/uac_isup_main1.xml
cat $SRC_PATH/uac_isup_2.txt >> $SRC_PATH/uac_isup_main1.xml

sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uas_isup_main.xml -recv_timeout 200s -timeout_error -s $NUM_CALLING -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_B &
sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uac_isup_main1.xml -recv_timeout 200s -timeout_error -s $NUM_CALLED -inf $TEMP_PATH/isup_inj.csv -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_A
REZULT
sleep 3


COUNT=4
# generic
# Формирование UAC

Full_seq_generic

cat $SRC_PATH/uac_isup_1.txt >> $SRC_PATH/uac_isup_main2.xml
echo "$FULL_SEQ_GENERIC" >> $SRC_PATH/uac_isup_main2.xml
cat $SRC_PATH/uac_isup_2.txt >> $SRC_PATH/uac_isup_main2.xml

sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uas_isup_main.xml -recv_timeout 200s -timeout_error -s $NUM_CALLING -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_B &
sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uac_isup_main2.xml -recv_timeout 200s -timeout_error -s $NUM_CALLED -inf $TEMP_PATH/isup_inj.csv -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_A
REZULT
sleep 3

QUALIFIER=7
COUNT=5
# Redir, origin, generic
# Формирование UAC

Full_seq_redir_generic

cat $SRC_PATH/uac_isup_1.txt >> $SRC_PATH/uac_isup_main3.xml
echo "$FULL_SEQ_REDIR_GENERIC" >> $SRC_PATH/uac_isup_main3.xml
cat $SRC_PATH/uac_isup_2.txt >> $SRC_PATH/uac_isup_main3.xml

sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uas_isup_main.xml -recv_timeout 200s -timeout_error -s $NUM_CALLING -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_B &
sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uac_isup_main3.xml -recv_timeout 200s -timeout_error -s $NUM_CALLED -inf $TEMP_PATH/isup_inj.csv -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_A
REZULT
sleep 3


COUNT=6
# generic
# Формирование UAC

Full_seq_generic      

cat $SRC_PATH/uac_isup_1.txt >> $SRC_PATH/uac_isup_main4.xml
echo "$FULL_SEQ_GENERIC" >> $SRC_PATH/uac_isup_main4.xml
cat $SRC_PATH/uac_isup_2.txt >> $SRC_PATH/uac_isup_main4.xml

sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uas_isup_main.xml -recv_timeout 200s -timeout_error -s $NUM_CALLING -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_B &
sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uac_isup_main4.xml -recv_timeout 200s -timeout_error -s $NUM_CALLED -inf $TEMP_PATH/isup_inj.csv -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_A
REZULT
sleep 3

QUALIFIER=1
COUNT=7
# Redir, origin, generic
# Формирование UAC

Full_seq_redir_generic

cat $SRC_PATH/uac_isup_1div.txt >> $SRC_PATH/uac_isup_main5.xml
echo "$FULL_SEQ_REDIR_GENERIC" >> $SRC_PATH/uac_isup_main5.xml
cat $SRC_PATH/uac_isup_2.txt >> $SRC_PATH/uac_isup_main5.xml

sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uas_isup_main.xml -recv_timeout 200s -timeout_error -s $NUM_CALLING -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_B &
sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uac_isup_main5.xml -recv_timeout 200s -timeout_error -s $NUM_CALLED -inf $TEMP_PATH/isup_inj.csv -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_A
REZULT
sleep 3

QUALIFIER=5
COUNT=8
# Redir, origin, generic
# Формирование UAC

Full_seq_redir_generic

cat $SRC_PATH/uac_isup_1div.txt >> $SRC_PATH/uac_isup_main6.xml
echo "$FULL_SEQ_REDIR_GENERIC" >> $SRC_PATH/uac_isup_main6.xml
cat $SRC_PATH/uac_isup_2.txt >> $SRC_PATH/uac_isup_main6.xml

sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uas_isup_main.xml -recv_timeout 200s -timeout_error -s $NUM_CALLING -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_B &
sudo $SIPP_PATH/sipp $SSWIP -sf $SRC_PATH/uac_isup_main6.xml -recv_timeout 200s -timeout_error -s $NUM_CALLED -inf $TEMP_PATH/isup_inj.csv -r 1 -l 1 -m 1 -i $SIPPIP -p $PORT_A
REZULT
sleep 3


# Удаляем файлы с данными
sudo rm $TEMP_PATH/$USER_A-$USER_B.csv
sudo rm $TEMP_PATH/$USER_B-$USER_A.csv

sudo rm $TEMP_PATH/isup_inj.csv
sudo rm $SRC_PATH/uac_isup_main.xml
sudo rm $SRC_PATH/uas_isup_main.xml
sudo rm $SRC_PATH/uac_isup_main1.xml
sudo rm $SRC_PATH/uac_isup_main2.xml
sudo rm $SRC_PATH/uac_isup_main3.xml
sudo rm $SRC_PATH/uac_isup_main4.xml
sudo rm $SRC_PATH/uac_isup_main5.xml
sudo rm $SRC_PATH/uac_isup_main6.xml


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
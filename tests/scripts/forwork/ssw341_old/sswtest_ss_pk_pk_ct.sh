#!/bin/bash

# Пути
SRC_PATH=~/test/ss_pk_pk_ct
TEMP_PATH=~/test/temp
mkdir $TEMP_PATH/ss_pk_pk_ct
LOG_PATH=~/test/log
SIPP_PATH=~/sipp



cp /dev/null $LOG_PATH/ss_pk_pk_ct.txt

#				Заполнение переменных

echo "filling variables" >> $LOG_PATH/ss_pk_pk_ct.txt
echo "filling variables"

SSW_IP_PORT=$4
SIPP_IP=$5

SSH_dom=$3
SSH_user=$1
SSH_pass=$2
SSH_host=$4

# default variables

pcap_path=..

num_A=500100
num_B=200112
num_C=200111
num_D=200110 # To change this variable, you must have correspoding pcap audio file 
num_E=200100

port_A=5061
port_B=5062
port_D=5160
port_C=5063
port_E=5064

ssw_dom_A=voip.local
ssw_dom_B=voip.local
ssw_dom_C=voip.local
ssw_dom_D=voip.local
ssw_dom_E=voip.local

PK_CODE="*08#"
HOLD_CODE=94
CTR_CODE=96

#				Активация pickup групп на ssw

echo "pickup grous activate" >> $LOG_PATH/ss_pk_pk_ct.txt
echo "pickup grous activate"
$SRC_PATH/sswconf_pk_gr_on.sh $SSH_host $SSH_user $SSH_pass $SSH_dom $SSH_dom $SSH_dom $SSH_dom $num_B $num_C $num_D $num_E

#				Формирование инжекционных файлов

echo "injection files creation" >> $LOG_PATH/ss_pk_pk_ct.txt
echo "injection files creation"

touch $TEMP_PATH/ss_pk_pk_ct/"$num_E"_pk.csv
touch $TEMP_PATH/ss_pk_pk_ct/$num_D.csv
touch $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ch.csv
touch $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ct.csv
touch $TEMP_PATH/ss_pk_pk_ct/"$num_C"_pk.csv
touch $TEMP_PATH/ss_pk_pk_ct/$num_B.csv
touch $TEMP_PATH/ss_pk_pk_ct/$num_A.csv

touch $SRC_PATH/002_uac_ssw_pk_ctr2.xml

#				Заполнение инжекционных файлов

echo "filling injection files" >> $LOG_PATH/ss_pk_pk_ct.txt
echo "filling injection files"

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_pk_pk_ct/"$num_E"_pk.csv
echo "$num_E;$ssw_dom_E;$PK_CODE;" >> $TEMP_PATH/ss_pk_pk_ct/"$num_E"_pk.csv

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_pk_pk_ct/$num_D.csv
echo "$num_D;$ssw_dom_D;" >> $TEMP_PATH/ss_pk_pk_ct/$num_D.csv

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ch.csv
echo "$num_C;$ssw_dom_C;*$HOLD_CODE#;;#$HOLD_CODE#;" >> $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ch.csv

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ct.csv
echo "$num_C;$ssw_dom_C;*$CTR_CODE#;;#$CTR_CODE#;" >> $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ct.csv

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_pk_pk_ct/"$num_C"_pk.csv
echo "$num_C;$ssw_dom_C;$PK_CODE;" >> $TEMP_PATH/ss_pk_pk_ct/"$num_C"_pk.csv

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_pk_pk_ct/$num_B.csv
echo "$num_B;$ssw_dom_B;" >> $TEMP_PATH/ss_pk_pk_ct/$num_B.csv

echo "SEQUENTIAL;" >> $TEMP_PATH/ss_pk_pk_ct/$num_A.csv
echo "$num_A;$ssw_dom_A;$num_B;" >> $TEMP_PATH/ss_pk_pk_ct/$num_A.csv

#				Формирование sipp сценария 002_uac_ssw_pk_ctr2.xml

echo "filling 002_uac_ssw_pk_ctr2.xml scenario" >> $LOG_PATH/ss_pk_pk_ct.txt
echo "filling 002_uac_ssw_pk_ctr2.xml scenario"

cat $SRC_PATH/for_sipp_sc/part1.txt >> $SRC_PATH/002_uac_ssw_pk_ctr2.xml
echo "<exec play_pcap_audio=\"$pcap_path/test/audio/$num_D.pcap\"/>" >> $SRC_PATH/002_uac_ssw_pk_ctr2.xml
cat $SRC_PATH/for_sipp_sc/part2.txt >> $SRC_PATH/002_uac_ssw_pk_ctr2.xml
echo "<exec play_pcap_audio=\"$pcap_path/test/audio/dtmf4.pcap\"/>" >> $SRC_PATH/002_uac_ssw_pk_ctr2.xml
cat $SRC_PATH/for_sipp_sc/part3.txt >> $SRC_PATH/002_uac_ssw_pk_ctr2.xml

#				Запуск sipp сценариев
REZULT=0

sudo $SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/ss_pk_pk_ct/$num_A.csv -mi $SIPP_IP -s $num_A -ap $num_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_A -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "registration A FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "registration A SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
  fi

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/ss_pk_pk_ct/$num_D.csv -mi $SIPP_IP -s $num_D -ap $num_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_D -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "registration D FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "registration D SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
  fi

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/ss_pk_pk_ct/$num_B.csv -mi $SIPP_IP -s $num_B -ap $num_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_B -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "registration B FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "registration B SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
  fi

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/ss_pk_pk_ct/"$num_E"_pk.csv -mi $SIPP_IP -s $num_E -ap $num_E -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_E -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "registration E FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "registration E SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
  fi

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/reg_auth.xml -inf $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ch.csv -mi $SIPP_IP -s $num_C -ap $num_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_C -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "registration C FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "registration C SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
  fi

# Activate SS

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/uac_f2_act_ss.xml -inf $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ch.csv -mi $SIPP_IP -s $num_C -ap $num_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_C -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "activation CH on C FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "activation CH on C SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
  fi

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/uac_f2_act_ss.xml -inf $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ct.csv -mi $SIPP_IP -s $num_C -ap $num_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_C -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "activation CT on C FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "activation CT on C SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt  
  fi

# Run USER B and D scrfypt
$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/009_uas_ssw.xml -mi $SIPP_IP -m 1 -nd -i $SIPP_IP -p $port_B -timeout 600 -timeout_error &
$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/009_uas_ssw.xml -mi $SIPP_IP -m 1 -nd -i $SIPP_IP -p $port_D -timeout 600 -timeout_error &

# Call from A to B
$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/002_uac_ssw_pk_ctr.xml -inf $TEMP_PATH/ss_pk_pk_ct/$num_A.csv -mi $SIPP_IP -s $num_A -ap $num_A -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_A -timeout 600 -timeout_error &

# User C  pickup, hold, new call and transfer
sudo $SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/002_uac_ssw_pk_ctr2.xml -inf $TEMP_PATH/ss_pk_pk_ct/"$num_C"_pk.csv -mi $SIPP_IP -s $num_C -ap $num_C -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_C -sleep 10 -timeout 600 -timeout_error &
sleep 2

# User E pickup
$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/001_uac_ssw_pk_ctr.xml -inf $TEMP_PATH/ss_pk_pk_ct/"$num_E"_pk.csv -mi $SIPP_IP -s $num_E -ap $num_E -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_E -sleep 45 -timeout 600 -timeout_error
  if test $? -ne 0
      then 
          echo "Test FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "Test SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt  
  fi

sleep 3

# Dectivate SS

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/uac_f4_deact_ss.xml -inf $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ch.csv -mi $SIPP_IP -s $num_C -ap $num_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_C -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "deactivation CH on C FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "deactivation CH on C SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt  
  fi

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/uac_f4_deact_ss.xml -inf $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ct.csv -mi $SIPP_IP -s $num_C -ap $num_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_C -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "deactivation CT on C FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "deactivation CT on C SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt  
  fi

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/ss_pk_pk_ct/$num_A.csv -mi $SIPP_IP -s $num_A -ap $num_A -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_A -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "unregistration A FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "unregistration A SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
  fi
$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/ss_pk_pk_ct/$num_D.csv -mi $SIPP_IP -s $num_D -ap $num_D -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_D -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "unregistration D FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "unregistration D SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
  fi

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/ss_pk_pk_ct/$num_B.csv -mi $SIPP_IP -s $num_B -ap $num_B -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_B -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "unregistration B FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "unregistration B SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
  fi

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/ss_pk_pk_ct/"$num_E"_pk.csv -mi $SIPP_IP -s $num_E -ap $num_E -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_E -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "unregistration E FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "unregistration E SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
  fi

$SIPP_PATH/sipp $SSW_IP_PORT -sf $SRC_PATH/reg_auth0.xml -inf $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ch.csv -mi $SIPP_IP -s $num_C -ap $num_C -rtp_echo -l 1 -r 1 -m 1 -nd -i $SIPP_IP -p $port_C -timeout 10 -timeout_error
  if test $? -ne 0
      then 
          echo "unregistration C FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
          REZULT=$[$REZULT+1]
      else 
          echo "unregistration C SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
  fi

#				Деактивация pickup групп на ssw

echo "pickup grous deactivate" >> $LOG_PATH/ss_pk_pk_ct.txt
echo "pickup grous deactivate"
$SRC_PATH/sswconf_pk_gr_off.sh $SSH_host $SSH_user $SSH_pass $SSH_dom $SSH_dom $SSH_dom $SSH_dom $num_B $num_C $num_D $num_E

#				Обработка результатов теста

  if test $REZULT -ne 0
      then 
          echo "TEST FAILED!!!" >> $LOG_PATH/ss_pk_pk_ct.txt
	  echo "TEST FAILED!!!"
      else 
          echo "TEST SUCCESSFUL" >> $LOG_PATH/ss_pk_pk_ct.txt
	  echo "TEST SUCCESSFUL"
  fi
#				Удаление инжекционных файлов

rm $TEMP_PATH/ss_pk_pk_ct/"$num_E"_pk.csv
rm $TEMP_PATH/ss_pk_pk_ct/$num_D.csv
rm $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ch.csv
rm $TEMP_PATH/ss_pk_pk_ct/"$num_C"_ct.csv
rm $TEMP_PATH/ss_pk_pk_ct/"$num_C"_pk.csv
rm $TEMP_PATH/ss_pk_pk_ct/$num_B.csv
rm $TEMP_PATH/ss_pk_pk_ct/$num_A.csv

rm $SRC_PATH/002_uac_ssw_pk_ctr2.xml

echo "injection files removed" >> $LOG_PATH/ss_pk_pk_ct.txt
echo "injection files removed"

echo "--------------------------------" >> $LOG_PATH/ss_pk_pk_ct.txt

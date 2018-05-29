#!/bin/bash
# COPM test. Command 1-4
# Set source
SRC_PATH=~/test/sorm
TEMP_PATH=~/test/temp

# $1 Default password
# $2 New password
# $3 ORM number

# Define variables
#PASS_DEF=123456
#PASS_SET=333333
#ORM_NUM=0
#IP_ADDR=192.168.118.98
PASS_DEF=$1
PASS_SET=$2
ORM_NUM=$3
IP_ADDR=$4

# Create file
echo "[CMD_NUMBER]" > $SRC_PATH/testsorm5.cmd
echo "NUM=22" >> $SRC_PATH/testsorm5.cmd
echo "DEST=$IP_ADDR" >> $SRC_PATH/testsorm5.cmd  

#5.1
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.01.01" >> $SRC_PATH/testsorm5.cmd

#5.2
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.02.FF" >> $SRC_PATH/testsorm5.cmd

#5.3
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.03.05" >> $SRC_PATH/testsorm5.cmd

#5.4
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.0B.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.FF.FF.FF.FF" >> $SRC_PATH/testsorm5.cmd

#5.5
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.04.05" >> $SRC_PATH/testsorm5.cmd

#5.6
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.FE.FF" >> $SRC_PATH/testsorm5.cmd

#5.7
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.06.FF" >> $SRC_PATH/testsorm5.cmd

#5.8
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.07.FF" >> $SRC_PATH/testsorm5.cmd

#5.10
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.07.07" >> $SRC_PATH/testsorm5.cmd

#5.11
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.FE.08" >> $SRC_PATH/testsorm5.cmd

#5.12
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.07.FE" >> $SRC_PATH/testsorm5.cmd

#5.13
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.06.08" >> $SRC_PATH/testsorm5.cmd

#5.14
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.07.06" >> $SRC_PATH/testsorm5.cmd

#5.16
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.FF.07.08" >> $SRC_PATH/testsorm5.cmd

#5.17
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.03.01.05.FF" >> $SRC_PATH/testsorm5.cmd

#COUNT=$(($COUNT+1))
#echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
#echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
#echo "SEND=0F" >> $SRC_PATH/testsorm5.cmd
#echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.03.01.25.FF" >> $SRC_PATH/testsorm5.cmd

#COUNT=$(($COUNT+1))
#echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
#echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
#echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
#echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.03.25.FF" >> $SRC_PATH/testsorm5.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.0B.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.FF.FF.FF.FF" >> $SRC_PATH/testsorm5.cmd

#5.18
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.01.05.05" >> $SRC_PATH/testsorm5.cmd

########### add command number 5 #########################
COUNT=$(($COUNT+1))
#echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
#echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
#echo "SEND=0F" >> $SRC_PATH/testsorm5.cmd
#echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.FF.01.09.09" >> $SRC_PATH/testsorm5.cmd

#echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
#echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
#echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
#TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
#PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
#NUMB=$NUM1
#TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
#KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
#KSL=02 #KSL group
#PRIO=02 #01-prio, 02-usual
#echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}
#.01.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.
#FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.05.FF" >> $SRC_PATH/testsorm5.cmd

#5.19
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.11.05.06" >> $SRC_PATH/testsorm5.cmd

########### add command number 5 #########################
COUNT=$(($COUNT+1))
#echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
#echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
#echo "SEND=0F" >> $SRC_PATH/testsorm5.cmd
#echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.FF.01.09.09" >> $SRC_PATH/t$

#echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
#echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
#echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
#TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
#PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
#NUMB=$NUM1
#TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
#KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
#KSL=02 #KSL group
#PRIO=02 #01-prio, 02-usual
#echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}
#.01.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.
#FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm5.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm5.cmd 
echo "SEND=0E" >> $SRC_PATH/testsorm5.cmd
echo "CMD=00.CC.0$ORM_NUM.09.03.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.05.06" >> $SRC_PATH/testsorm5.cmd




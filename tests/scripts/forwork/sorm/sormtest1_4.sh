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
echo "[CMD_NUMBER]" > $SRC_PATH/testsorm14.cmd
echo "NUM=22" >> $SRC_PATH/testsorm14.cmd
echo "DEST=$IP_ADDR" >> $SRC_PATH/testsorm14.cmd  

# 1.2
COUNT=1
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd
echo "SEND=11" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.03.06.3${PASS_DEF:0:1}.3${PASS_DEF:1:1}.3${PASS_DEF:2:1}.3${PASS_DEF:3:1}.3${PASS_DEF:4:1}.3${PASS_DEF:5:1}.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}" >> $SRC_PATH/testsorm14.cmd

#2.1-2.3
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0B" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.01.00.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0B" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.01.00.3${PASS_DEF:0:1}.3${PASS_DEF:1:1}.3${PASS_DEF:2:1}.3${PASS_DEF:3:1}.3${PASS_DEF:4:1}.3${PASS_DEF:5:1}" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0B" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.01.00.3${PASS_DEF:0:1}.3${PASS_DEF:1:1}.3${PASS_DEF:2:1}.3${PASS_DEF:3:1}.3${PASS_DEF:4:1}.3${PASS_DEF:5:1}" >> $SRC_PATH/testsorm14.cmd

#3.1-3.4
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=11" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.03.06.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.3${PASS_DEF:0:1}.3${PASS_DEF:1:1}.3${PASS_DEF:2:1}.3${PASS_DEF:3:1}.3${PASS_DEF:4:1}.3${PASS_DEF:5:1}" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=11" >> $SRC_PATH/testsorm14.cmd
BAD_ORM_NUM=$(($ORM_NUM+1))
echo "CMD=00.CC.0$BAD_ORM_NUM.03.06.3${PASS_DEF:0:1}.3${PASS_DEF:1:1}.3${PASS_DEF:2:1}.3${PASS_DEF:3:1}.3${PASS_DEF:4:1}.3${PASS_DEF:5:1}.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=11" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.03.06.3${PASS_DEF:0:1}.3${PASS_DEF:1:1}.3${PASS_DEF:2:1}.3${PASS_DEF:3:1}.3${PASS_DEF:4:1}.3${PASS_DEF:5:1}.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=11" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.03.06.3${PASS_DEF:0:1}.3${PASS_DEF:1:1}.3${PASS_DEF:2:1}.3${PASS_DEF:3:1}.3${PASS_DEF:4:1}.3${PASS_DEF:5:1}.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}" >> $SRC_PATH/testsorm14.cmd

#4.1-4.5
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.01.01.01" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.01.02.FF" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.01.04.04" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.01.03.05" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.01.01.01" >> $SRC_PATH/testsorm14.cmd

#4.6-4.10
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.01.3E.3E" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.11.03.05" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.03.11.07.08" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.11.06.25" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.0B.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.FF.FF.FF.FF" >> $SRC_PATH/testsorm14.cmd

#4.11-4.14
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.01.11.09.0A" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.01.09.09" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.11.07.09" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.11.08.09" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.11.04.09" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.11.09.07" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.11.09.08" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.11.09.04" >> $SRC_PATH/testsorm14.cmd

#4.15-4.18
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.02.11.09.09" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.FF.01.09.09" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.03.FE.09.09" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.03.17.09.09" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.03.01.FE.FF" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.03.01.75.FF" >> $SRC_PATH/testsorm14.cmd

#4.x add two groups
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.04.01.10.FF" >> $SRC_PATH/testsorm14.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm14.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm14.cmd 
echo "SEND=0F" >> $SRC_PATH/testsorm14.cmd
echo "CMD=00.CC.0$ORM_NUM.04.04.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}.05.11.11.12" >> $SRC_PATH/testsorm14.cmd




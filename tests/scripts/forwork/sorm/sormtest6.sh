#!/bin/bash
# COPM test. Command 5
# Set source
SRC_PATH=~/test/tests/scripts/sorm
TEMP_PATH=~/test/temp

# Define variables
#PASS_DEF=123456
#PASS_SET=333333
#ORM_NUM=0
#IP_ADDR=192.168.118.98
PASS_DEF=$1
PASS_SET=$2
ORM_NUM=$3
IP_ADDR=$4

NUM1=73832200500 #local user
NUM2=73832200110 # local user 2
NUM3=73832800100 # PSTN user rus
NUM4=73832800101 # PSTN user foreign
NUM_SS=01 #Emergency Number
NUM5="$NUM_SS"FFFFFFFFF
NUM6=7383280020F #Not complete number with FF spare to 11 digits (ten digits in number)
NUM7=7383280021F #Not complete number with FF spare to 11 digits (ten digits in number)
NUM8=7383280022F #Not complete number with FF spare to 11 digits (ten digits in number)
NUM9=73832200110 # local user 3
NUM10=73832800102 # PSTN user rus 2
NUM11=73832200111 # local user 4
NUM12=73832200112 # local user 5
NUM13=73832200113 # local user 6
NUM14=73832800109 #Not local number
NUM15=73832800200 # Complete PSTN number same as not cimplete num6
NUM16=7383280010F # Not complete num same as complete num10

# Create file
echo "[CMD_NUMBER]" > $SRC_PATH/testsorm6.cmd
echo "NUM=22" >> $SRC_PATH/testsorm6.cmd
echo "DEST=$IP_ADDR" >> $SRC_PATH/testsorm6.cmd

#6.1
COUNT=1
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM1
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.01.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM2
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=01 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.02.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.2
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=02 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=04 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM3
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.03.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=02 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=05 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM4
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=01 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=01 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.04.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=02 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=06 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM5
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=01 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.05.00.$TYPE.$PRIZN.02.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.3
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=03 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=FF #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=FFFFFFFFFFF
TG_NUM=01.00 #TG num, if FF.FF then trunk not used (для транка 1)
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=01 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.06.00.$TYPE.$PRIZN.FF.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.4
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=12 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=04 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM6
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=01 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.07.00.$TYPE.$PRIZN.0A.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=12 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=05 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM7
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=01 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=01 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.08.00.$TYPE.$PRIZN.0A.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.5
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM8
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=01 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=01 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.09.00.$TYPE.$PRIZN.0A.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.6
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM9
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=01 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.08.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.7
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=02 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=04 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM10
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.08.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.8
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd    
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd     
TYPE=03 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=FF #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=FFFFFFFFFFF
TG_NUM=00.02 #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=01 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.08.00.$TYPE.$PRIZN.00.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.9
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM2
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=01 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.0A.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.10
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM2
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=01 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.08.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.11
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd 
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM11
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=01 #KSL group
PRIO=01 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.0B.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.12
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd 
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM12
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=09 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.0C.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.13
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd 
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM13
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.0D.00.$TYPE.$PRIZN.0A.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.14
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd 
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM14
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.0E.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.15
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=12 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM8
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=01 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=01 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.0F.00.$TYPE.$PRIZN.0A.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.16
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=08 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM9
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=01 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=01 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.10.00.$TYPE.$PRIZN.0A.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.17
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=08 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM9
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=01 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=01 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.11.00.$TYPE.$PRIZN.0A.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.18
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM9
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=08 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=01 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.12.00.$TYPE.$PRIZN.0A.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.19
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM9
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=01 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=FE #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.13.00.$TYPE.$PRIZN.0A.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.20
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM9
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=01 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=01 #KSL group
PRIO=09 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.14.00.$TYPE.$PRIZN.0A.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.23
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=01 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=01 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=FFFFFFFFFFF
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=01 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=01 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.15.00.$TYPE.$PRIZN.FF.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=03 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=FF #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=FFFFFFFFFFF
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=01 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=01 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.16.00.$TYPE.$PRIZN.FF.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.24
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=02 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=04 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM15
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.17.00.$TYPE.$PRIZN.0B.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd

#6.25
COUNT=$(($COUNT+1))
echo "[CMD_$COUNT]" >> $SRC_PATH/testsorm6.cmd
echo "PAUSE=04" >> $SRC_PATH/testsorm6.cmd 
echo "SEND=1E" >> $SRC_PATH/testsorm6.cmd
TYPE=12 #01-abonent dannogo uzla, 02-PSTN, 12-PSTN not complete, 03-trunk
PRIZN=04 #01-abonent dannogo uzla, 04-PSTNrus, 05-PSTNforeign, 06-specslugby, FF-when trunk use
NUMB=$NUM16
TG_NUM=FF.FF #TG num, if FF.FF then trunk not used
KONTR=11 #type: 01-full control (duplex), 11-full control (half dupl), 02-statistic
KSL=02 #KSL group
PRIO=02 #01-prio, 02-usual
echo "CMD=00.CC.0$ORM_NUM.05.13.3${PASS_SET:0:1}.3${PASS_SET:1:1}.3${PASS_SET:2:1}.3${PASS_SET:3:1}.3${PASS_SET:4:1}.3${PASS_SET:5:1}\
.18.00.$TYPE.$PRIZN.0A.${NUMB:1:1}${NUMB:0:1}.${NUMB:3:1}${NUMB:2:1}.${NUMB:5:1}${NUMB:4:1}.${NUMB:7:1}${NUMB:6:1}.${NUMB:9:1}${NUMB:8:1}.F${NUMB:10:1}.\
FF.FF.FF.$TG_NUM.$KONTR.$KSL.$PRIO" >> $SRC_PATH/testsorm6.cmd


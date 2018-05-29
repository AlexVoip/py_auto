#!/bin/bash
# COPM res. Command 1-4
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
ORM_VERS=02 # 02 - 268 prikaz
ORM_NUM=$1
FILENAME=$2

E_NOFILE=2

sudo rm $TEMP_PATH/tempsorm14.txt

# Create file
if [ ! -f "$SRC_PATH/$FILENAME" ]       # If file exist
then
  echo "File \"$FILENAME\" not found"
  exit $E_NOFILE
fi

cat $SRC_PATH/$2 | grep MSG > $TEMP_PATH/tempsorm14.txt

COUNT=0
while read line
do
COUNT=$(($COUNT+1))
STR[COUNT]=$line
#echo "${STR[COUNT]}"
done < $TEMP_PATH/tempsorm14.txt

if [[ ${STR[1]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.03.02* ]]
then
echo "Test 1.2 SUCCESS"
else
echo "Test 1.2 FAIL"
fi

if ([[ ${STR[2]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.01.00* ]] &&
    [[ ${STR[4]} == MSG3=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.01.03* ]] &&
    [[ ${STR[3]} == MSG2=00.CC.0$ORM_NUM.26.2D.01.00.01.00.FF.$ORM_VERS.02.* ]])
	    then 
		IFS='.' read -a array <<< "${STR[3]}"
		i=17
		temp=.
                while [ $i -le 55 ]
                do
                temp="$temp${array[i]}"
                i=$(($i+1))
		#echo "$temp"
        	done
        #       if [[ "$temp" == .000000000000000000000000000000000000000000000000000000000000000000000000000000* ]]
                if [[ "$temp" == .FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF* ]]
                then
		        echo "Test 2.1 SUCCESS"
		        else
		        echo "Test 2.1 FAIL"
		fi
            else
            echo "Test 2.1 FAIL"
fi

if ([[ ${STR[5]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.01.00* ]] &&
    [[ ${STR[6]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.01.00* ]])
       then
       echo "Test 2.2 SUCCESS"
       else 
       echo "Test 2.2 FAIL"
fi

if ([[ ${STR[7]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.01.00* ]] &&
    [[ ${STR[8]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.01.07* ]])
then
echo "Test 2.3 SUCCESS"
else
echo "Test 2.3 FAIL"
fi

if ([[ ${STR[9]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.03.00* ]] &&
    [[ ${STR[11]} == MSG3=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.03.03* ]] &&
    [[ ${STR[10]} == MSG2=00.CC.0$ORM_NUM.26.2D.01.00.01.00.FF.$ORM_VERS.02.* ]])
then
IFS='.' read -a array <<< "${STR[10]}"
i=17
temp=.
while [ $i -le 55 ]
do
temp="$temp${array[i]}"
i=$(($i+1))
#echo "$temp"  
done
#       if [[ "$temp" == .000000000000000000000000000000000000000000000000000000000000000000000000000000* ]]
if [[ "$temp" == .FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF* ]]
then
echo "Test 3.1 SUCCESS"
else
echo "Test 3.1 FAIL"
fi
else
echo "Test 3.1 FAIL"
fi

if ([[ ${STR[12]} == MSG1=00.CC.0$(($ORM_NUM+1)).27.02.01.00.01.00.FF.$ORM_VERS.03.00* ]] &&
    [[ ${STR[14]} == MSG3=00.CC.0$(($ORM_NUM+1)).28.02.01.00.01.00.FF.$ORM_VERS.03.05* ]] &&
    [[ ${STR[13]} == MSG2=00.CC.0$(($ORM_NUM+1)).26.2D.01.00.01.00.FF.$ORM_VERS.05.* ]])
then
IFS='.' read -a array <<< "${STR[13]}"
i=17
temp=.
while [ $i -le 55 ]
do
temp="$temp${array[i]}"
i=$(($i+1))
#echo "$temp"  
done
#       if [[ "$temp" == .000000000000000000000000000000000000000000000000000000000000000000000000000000* ]]
if [[ "$temp" == .FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF* ]]
then
echo "Test 3.2 SUCCESS"
else
echo "Test 3.2 FAIL"
fi
else
echo "Test 3.2 FAIL"
fi

if ([[ ${STR[15]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.03.00* ]] &&
    [[ ${STR[16]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.03.00* ]])
then
echo "Test 3.3 SUCCESS"
else
echo "Test 3.3 FAIL"
fi

if ([[ ${STR[17]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.03.00* ]] &&
    [[ ${STR[19]} == MSG3=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.03.03* ]] &&
    [[ ${STR[18]} == MSG2=00.CC.0$ORM_NUM.26.2D.01.00.01.00.FF.$ORM_VERS.02.* ]])
then
IFS='.' read -a array <<< "${STR[18]}"
i=17  
temp=.
while [ $i -le 55 ]
do
temp="$temp${array[i]}"
i=$(($i+1))
#echo "$temp"  
done
#       if [[ "$temp" == .000000000000000000000000000000000000000000000000000000000000000000000000000000* ]]
if [[ "$temp" == .FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF* ]]
then
echo "Test 3.4 SUCCESS"
else
echo "Test 3.4 FAIL"
fi
else
echo "Test 3.4 FAIL"
fi

if ([[ ${STR[20]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[21]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.00* ]])
then
echo "Test 4.1 SUCCESS"
else
echo "Test 4.1 FAIL"
fi

if ([[ ${STR[22]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[23]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.00* ]])
then
echo "Test 4.2 SUCCESS"
else
echo "Test 4.2 FAIL"
fi

if ([[ ${STR[24]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[25]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.00* ]])
then
echo "Test 4.3 SUCCESS"
else
echo "Test 4.3 FAIL"
fi

if [[ ${STR[26]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.11* ]]
then
echo "Test 4.4 SUCCESS"
else
echo "Test 4.4 FAIL"
fi

if ([[ ${STR[27]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[28]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.3A* ]])
then
echo "Test 4.5 SUCCESS"
else
echo "Test 4.5 FAIL"
fi

if [[ ${STR[29]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.11* ]]
then
echo "Test 4.6 SUCCESS"
else
echo "Test 4.6 FAIL"
fi

if ([[ ${STR[30]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[31]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.00* ]])
then
echo "Test 4.7 SUCCESS"
else
echo "Test 4.7 FAIL"
fi

if ([[ ${STR[32]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[33]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.00* ]])
then
echo "Test 4.8 SUCCESS"
else
echo "Test 4.8 FAIL"
fi

if [[ ${STR[34]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.11* ]]
then
echo "Test 4.9 SUCCESS"
else
echo "Test 4.9 FAIL"
fi

if ([[ ${STR[35]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.0B.00* ]] && 
    [[ ${STR[37]} == MSG3=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.0B.00* ]] && 
    [[ ${STR[36]} == MSG2=00.CC.0$ORM_NUM.24.2D.01.00.01.00.FF.$ORM_VERS.01.01.01.FF.01.01.02.FF.01.01.04.FF.02.11.03.05.03.11.07.08.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF.FF* ]])
then
echo "Test 4.10 SUCCESS"
else
echo "Test 4.10 FAIL"
fi

if ([[ ${STR[38]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[39]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.30* ]])
then
echo "Test 4.11 SUCCESS"
else
echo "Test 4.11 FAIL"
fi

if ([[ ${STR[40]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[41]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.30* ]])
then
echo "Test 4.12 SUCCESS"
else
echo "Test 4.12 FAIL"
fi

if ([[ ${STR[42]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[43]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.3A* ]])
then
echo "Test 4.13 SUCCESS"
else
echo "Test 4.13 FAIL"
fi

if ([[ ${STR[44]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[45]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.3A* ]])
then
echo "Test 4.13 SUCCESS"
else
echo "Test 4.13 FAIL"
fi

if ([[ ${STR[46]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[47]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.3A* ]])
then
echo "Test 4.13 SUCCESS"
else
echo "Test 4.13 FAIL"
fi

if ([[ ${STR[48]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[49]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.3A* ]])
then
echo "Test 4.14 SUCCESS"
else
echo "Test 4.14 FAIL"
fi

if ([[ ${STR[50]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[51]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.3A* ]])
then
echo "Test 4.14 SUCCESS"
else
echo "Test 4.14 FAIL"
fi

if ([[ ${STR[52]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[53]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.3A* ]])
then
echo "Test 4.14 SUCCESS"
else
echo "Test 4.14 FAIL"
fi

if ([[ ${STR[54]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[55]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.3B* ]])
then
echo "Test 4.15 SUCCESS"
else
echo "Test 4.15 FAIL"
fi

if [[ ${STR[56]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.11* ]]
then
echo "Test 4.16 SUCCESS"
else
echo "Test 4.16 FAIL"
fi

if [[ ${STR[57]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.14* ]]
then
echo "Test 4.17 SUCCESS"
else
echo "Test 4.17 FAIL"
fi

if [[ ${STR[58]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.14* ]]
then
echo "Test 4.17 SUCCESS"
else
echo "Test 4.17 FAIL"
fi

if [[ ${STR[59]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.11* ]]
then
echo "Test 4.18 SUCCESS"
else
echo "Test 4.18 FAIL"
fi

if [[ ${STR[60]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.11* ]]
then
echo "Test 4.18 SUCCESS"
else
echo "Test 4.18 FAIL"
fi

if ([[ ${STR[61]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[62]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.00* ]])
then
echo "Adv. Create KSL group 4 SUCCESS"
else
echo "Adv. Create KSL group 4 FAIL"
fi

if ([[ ${STR[63]} == MSG1=00.CC.0$ORM_NUM.27.02.01.00.01.00.FF.$ORM_VERS.04.00* ]] &&
    [[ ${STR[64]} == MSG2=00.CC.0$ORM_NUM.28.02.01.00.01.00.FF.$ORM_VERS.04.00* ]])
then
echo "Adv. Create KSL group 5 SUCCESS"
else
echo "Adv. Create KSL group 5 FAIL"
fi

exit 0


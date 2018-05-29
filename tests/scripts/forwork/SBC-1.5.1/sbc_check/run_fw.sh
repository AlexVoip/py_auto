#!/bin/sh

SHELL_PATH=/home/tester/autotest
FW_LIST=$SHELL_PATH/tests/scripts/SBC-1.5.1/sbc_check/fw_list
CH_LIST=$SHELL_PATH/tests/scripts/SBC-1.5.1/sbc_check/ch_list

echo $FW_LIST >> /home/tester/1.txt
echo $CH_LIST >> /home/tester/1.txt

RESULTS_PATH=$SHELL_PATH/tests/scripts/SBC-1.5.1/sbc_check/Результаты

echo "before test" >>  /home/tester/1.txt

if ! diff $FW_LIST $CH_LIST; then
    STR=`head -1 $FW_LIST`
    BOARD=`echo $STR | cut -f 2 -d ' '`
    VERSION=`echo $STR | cut -f 3 -d ' '`
    LINK=`echo $STR | cut -f 4 -d ' '`
    wget $LINK -O /tftpboot/sbc-1.5.1_firmware.bin
    echo "load firmware" >>  /home/tester/1.txt
    sudo /home/tester/autotest/main.py --run

    if [ $? -eq 0 ]; then
        RESULT="OK"
	EX=0
        echo "ok" >>  /home/tester/1.txt
    else
        RESULT="FAIL"
	EX=1
        echo "nok" >>  /home/tester/1.txt
    fi

    mkdir $RESULTS_PATH/${BOARD}-${VERSION}-${RESULT}
    WORKDIR=$RESULTS_PATH/${BOARD}-${VERSION}-${RESULT}
    tar -cvzf ${WORKDIR}/jobs.tar.gz -C $SHELL_PATH jobs

    echo "$RESULT"

    if [ $EX -eq 0 ]; then
        cp $FW_LIST $CH_LIST
    fi

fi

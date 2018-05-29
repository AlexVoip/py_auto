#!/bin/sh

SHELL_PATH=/home/tester/autotest

JENKINS_SCRIPT=$SHELL_PATH/tests/scripts/SBC-1.5.1/sbc_check/get_last_fw.sh

LAST_FW_NUMBER=`$JENKINS_SCRIPT | tail -1 | cut -f 1 -d ' '`
LAST_CHECKED_FW_NUMBER=`tail -1 $SHELL_PATH/tests/scripts/SBC-1.5.1/sbc_check/ch_list | cut -f 1 -d ' '`

CURRENT_FW_NUMBER=$LAST_FW_NUMBER

if [ -z $LAST_FW_NUMBER ] || [ -z $LAST_CHECKED_FW_NUMBER ]; then
    exit 1
fi

while true; do
    if [ $CURRENT_FW_NUMBER -le $LAST_CHECKED_FW_NUMBER ]; then
        RETVAL=1
        break
    fi

    STR=`$JENKINS_SCRIPT r $CURRENT_FW_NUMBER | tail -2 | head -1`
    echo $STR
    NUMBER=`echo $STR | cut -f 1 -d ' '`
    BOARD=`echo $STR | cut -f 2 -d ' '`
    VERSION=`echo $STR | cut -f 3 -d ' '`

    if [ $CURRENT_FW_NUMBER -ne $NUMBER ]; then
        RETVAL=1
        break
    fi

    if [ "x$BOARD" = "xSBC" ]; then
        echo $STR > $SHELL_PATH/tests/scripts/SBC-1.5.1/sbc_check/fw_list
        RETVAL=0
        break
    fi

    CURRENT_FW_NUMBER=$((CURRENT_FW_NUMBER-1))

done

echo "$CURRENT_FW_NUMBER"

exit $RETVAL

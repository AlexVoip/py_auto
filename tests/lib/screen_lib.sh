#!/bin/bash 
check_service_var () {
    if [ -z ${LOG_PATH}  ] || \
       [ -z ${TEMP_PATH}  ]
    then
        return 1
    else
        return 0
    fi
}

check_service_var

start_screen () {
    local name=$1
    local command=$2
    screen -d -m -S $name /bin/bash -c "$command"
    if test $? -ne 0;then
        return 1
    else
        return 0
    fi
}


stop_screen () {
    local scrn_name
    local name
    local mask=$1
    echo "Stop_screen function activated."
    echo "[DEBUG] Stop_screen function activated." >> $LOG_PATH/log.txt
    scrn_name=`screen -list | grep -ioE "$mask"`
    for name in $scrn_name; do
        screen -S $name -X "quit" >> /dev/null 2>&1
        echo "--> Session $name closed"
        echo "--> [DEBUG] Session $name closed" >> $LOG_PATH/log.txt
    done
    return 0
}

check_screen () {
    local mode=$1
    local name=$2
        rez=`screen -list | grep -oE $name`
        case $mode in
        open)
        if [ "$rez" == "" ];then
            echo "Error. Can't open the screen session $name"
            echo "[ERROR] {check_screen.function} Can't open the screen session $name" >> $LOG_PATH/log.txt
            return 1
        else
            echo "Session $name is opened"
            echo "[DEBUG] Session $name is opened" >> $LOG_PATH/log.txt
            return 0
        fi
        ;;
        close)
        if [ "$rez" != "" ];then
            return 1
        else
            return 0
        fi
        ;;
        *)
            echo "{check_screen.function} Bad param $mode"
        ;;
        esac
}

wait_uas () {
    local timer=0
    local name=$1
    echo "UAS not closed, waiting..."
    while true; do
        check_screen "close" "$name"
        if test $? -eq 0;then
            break
        fi
        if [ $timer -eq $2 ];then
            stop_screen "$name"
            echo "UAS $name EX_CODE 1 {break by timeout}" >> $TEMP_PATH/ex_code.txt
            return 99
	    break
        fi
    sleep 1s
    ((timer++))
    done
}





sudo_start_screen () {
    local name=$1
    local command=$2
    sudo screen -d -m -S $name /bin/bash -c "$command"
    if test $? -ne 0;then
        return 1
    else
        return 0
    fi
}


sudo_stop_screen () {
    local scrn_name
    local name
    local mask=$1
    echo "Stop_screen function activated."
    echo "[DEBUG] Stop_screen function activated." >> $LOG_PATH/log.txt
    scrn_name=`screen -list | grep -ioE "$mask"`
    for name in $scrn_name; do
        sudo screen -S $name -X "quit" >> /dev/null 2>&1
        echo "--> Session $name closed"
        echo "--> [DEBUG] Session $name closed" >> $LOG_PATH/log.txt
    done
    return 0
}

sudo_check_screen () {
    local mode=$1
    local name=$2
        rez=`sudo screen -list | grep -oE $name`
        case $mode in
        open)
        if [ "$rez" == "" ];then
            echo "Error. Can't open the screen session $name"
            echo "[ERROR] {check_screen.function} Can't open the screen session $name" >> $LOG_PATH/log.txt
            return 1
        else
            echo "Session $name is opened"
            echo "[DEBUG] Session $name is opened" >> $LOG_PATH/log.txt
            return 0
        fi
        ;;
        close)
        if [ "$rez" != "" ];then
            return 1
        else
            return 0
        fi
        ;;
        *)
            echo "{check_screen.function} Bad param $mode"
        ;;
        esac
}

sudo_wait_uas () {
    local timer=0
    local name=$1
    echo "UAS not closed, waiting..."
    while true; do
        sudo_check_screen "close" "$name"
        if test $? -eq 0;then
            break
        fi
        if [ $timer -eq $2 ];then
            sudo_stop_screen "$name"
            echo "UAS $name EX_CODE 1 {break by timeout}" >> $TEMP_PATH/ex_code.txt
            return 99
	    break
        fi
    sleep 1s
    ((timer++))
    done
}


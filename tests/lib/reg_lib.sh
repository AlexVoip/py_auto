#!/bin/bash
check_service_var () {
    if [ -z ${SIPP_PATH}  ] || \
       [ -z ${SRC_PATH}   ] || \
       [ -z ${EXTER_IP}   ] || \
       [ -z ${EXTER_PORT} ] || \
       [ -z ${TEMP_PATH}  ] || \
       [ -z ${IP}         ]
    then
        return 1
    else
        return 0
    fi
}


reg_user () {
    local number=$1
    local dom=$2
    local auth=$3
    local pass=$4
    local port=$5
    local exp=$6
    local i_count=""

    #Проверяем, что передано нужно количество параметров
    if test $# -gt 6; then
        echo "too many arguments. {function reg_user}" 1>&2
        return 1
    elif test $# -lt 6; then
        echo "too few arguments. {function reg_user}" 1>&2
        return 1
    fi

    #Проверяем, что конфигурационный файл с настройками подключен к скрипту
    check_service_var
    if test $? -ne 0; then
        echo "No service variables! Include custom config. {function reg_user}" 1>&2
        return 1;
    fi

    #Проверяем, что переданные аргументы не являются пустой сторокой
    for i_count in `seq 1 $#`; do
        if [ -z "$1" ]; then
            echo "Some of arguments are equal \"\". {function reg_user}".  1>&2
            return 1
        fi
        shift 1
    done


    ${SIPP_PATH}/sipp -sf ${SRC_PATH}/reg_user.xml ${EXTER_IP}:${EXTER_PORT} -i ${IP} -s ${auth} -ap ${pass} -set DOMAIN ${dom} -set PORT ${port} -set EXPIRES ${exp} -set NUMBER ${number} -m 1
    return $?
}




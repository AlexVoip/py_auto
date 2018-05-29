check_service_var () {
    if [ -z ${DEV_DOM}     ] || \
       [ -z ${DEV_USER}    ] || \
       [ -z ${DEV_PASS}    ] || \
       [ -z ${SERV_IP}     ] || \
       [ -z ${SERV_IP}     ] || \
       [ -z ${EXPECT_PATH} ]
    then
        return 1
    else
        return 0
    fi
}

set_ss () {
    local number=$1
    local ss=$2
    local mode=$3
    local command=""

    if test $# -gt 3; then
        echo "too many arguments. {set_ss}" 1>&2
        return 1
    elif test $# -lt 3; then
        echo "too few arguments. {function set_ss}" 1>&2
        return 1
    fi

    #Проверяем, что конфигурационный файл с настройками подключен к скрипту
    check_service_var
    if test $? -ne 0; then
        echo "No service variables! Include custom config. {function set_ss}" 1>&2
        return 1;
    fi

    #Проверяем, что переданные аргументы не являются пустой сторокой
    for i_count in `seq 1 $#`; do
        if [ -z "$1" ]; then
            echo "Some of arguments are equal \"\". {function set_ss}".  1>&2
            return 1
        fi
        shift 1
    done

    case "${mode}" in
    enable)
        command="/domain/${DEV_DOM}/ss/enable ${number} ${ss}"
        ${EXPECT_PATH}/expect.sh "${DEV_USER}" "${DEV_PASS}" "${SERV_IP}" "${command}" 1>>${LOG_PATH}/expect.log 2>&1
        return $?
    ;;
    disable)
        command="/domain/${DEV_DOM}/ss/disable ${number} ${ss}"
        ${EXPECT_PATH}/expect.sh "${DEV_USER}" "${DEV_PASS}" "${SERV_IP}" "${command}" 1>>${LOG_PATH}/expect.log 2>&1
        return $?
    ;;
    *)
        echo "Invlid mode. {function set_ss}".  1>&2
        return 1
    esac
}


mgm_ss () {
    local number=$1
    local ss=$2
    local mode=$3
    local options=$4
    local command=""

    if test $# -gt 4; then
        echo "too many arguments. {function mgm_ss}" 1>&2
        return 1
    elif test $# -lt 4; then
        echo "too few arguments. {function mgm_ss}" 1>&2
        return 1
    fi

    #Проверяем, что конфигурационный файл с настройками подключен к скрипту
    check_service_var
    if test $? -ne 0; then
        echo "No service variables! Include custom config. {function mgm_ss}" 1>&2
        return 1;
    fi

    #Проверяем, что переданные аргументы не являются пустой сторокой
    for i_count in `seq 1 $#`; do
        if [ -z "$1" ]; then
            echo "Some of arguments are equal \"\". {function mgm_ss}".  1>&2
            return 1
        fi
        shift 1
    done

    case "${mode}" in
    activate)
        command="/domain/${DEV_DOM}/ss/activate ${number} ${ss} ${options}"
        ${EXPECT_PATH}/expect.sh "${DEV_USER}" "${DEV_PASS}" "${SERV_IP}" "${command}" 1>>${LOG_PATH}/expect.log 2>&1
        return $?
    ;;
    deactivate)
        command="/domain/${DEV_DOM}/ss/deactivate ${number} ${ss}"
        ${EXPECT_PATH}/expect.sh "${DEV_USER}" "${DEV_PASS}" "${SERV_IP}" "${command}" 1>>${LOG_PATH}/expect.log 2>&1
        return $?
    ;;
    *)
        echo "Invlid mode. {function mgm_ss}".  1>&2
        return 1
    esac
}



#!/bin/bash
##############################################################################
#                                                                            #
#                           Follow me test V 3.0                             #
#                                                                            #
##############################################################################

#-----> VARIBLES


#Test settings
PORT_MASS=("5060" "5063" "5160")                	#Порты используемые абонентами
NUMB_MASS=("200100" "500100" "200110")                   	#Номера телефонов
USER_PASS=("200100" "500100" "200110")                  		#Пароль для абонентов
USER_DOM=("voip.local" "voip.local" "voip.local")	  	#Домен абонентов
GROUP_NAME=("voip.local" "voip.local" "voip.local" )               	#Группа абоентов
USER_PIN=1111
PRIZN=$6
KOD_SS=23

#Network settings
EXT_IP=$4                            	#IP адрес ВАТС
EXT_PORT=5060                                   	#Порт ВАТС
LOC_IP=$5                             		#Локальный IP
SERVICE_IP=192.168.18.18                       		#IP для сбора статистики

#Paths
SIPP_PATH="$HOME/sipp"               	#Путь к sipp
XML_PATH="$HOME/test/ss_followme"                     	#Путь к скриптам
LOG_PATH1="$HOME/test/temp" 
LOG_PATH="$HOME/test/temp/followme"                       	#Путь к логам и временным файлам

#Counts
FAIL_COUNT=0                                    	#Счётчик удачных вызовов
SUCC_COUNT=0                                    	#Счётчик неудачных вызовов

#CoCoN Settings
USERNAME=$1                                  	#Логин
PASSWORD=$2                               	#Пароль
SSW_IP=$4                            	#IP адрес SSW
DOMAIN_NAME=$3                         	#Имя домена

#Flags
CSV_FLAG=0                                      	#Флаг создания временных файлов
ACT_MGM_FLAG=0                                  	#Флаг активации услуги MGM
ACT_FM_FLAG=0                                   	#Флаг активации follow_me
PER_FLAG=0                                      	#Флаг установки прав
REG_FLAG=0                                      	#Флаг регистрации абонентов

#-----> Functions


# Функция подсчета успешных и неуспешных вызовов
create_file (){
    new_file=$1
    if touch $new_file > /dev/null 2>&1; then
        : > $new_file
        echo "File $new_file successfully created"
    else
        echo "Error. Can't create $new_file"
        exit 1
    fi
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
        if [ $timer -eq 150 ];then
            stop_screen "$name"
            echo "UAS $name EX_CODE 1 {break by timeout}" >> $LOG_PATH/ex_code.txt
            break
        fi
    sleep 1s
    ((timer++))
    done
}

result ()
{
    local mode=$1
    case $mode in
        succ) ((SUCC_COUNT++));;
        fail) ((FAIL_COUNT++));;
    esac
}

set_permissions () {
    local number=$1
    #Устанавливаем права абонентам на follow_me и mgm
    COMMAND="/domain/$DOMAIN_NAME/ss/permissions change $number --unlock --enable mgm follow_me"
    $XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$COMMAND" >> /dev/null 2>>$LOG_PATH/error.log
    if test $? -ne 0; then
        echo "Error. Can't exec expect.sh (set perm $number)"
        echo "[ERROR] Can't exec expect.sh (set perm $number)" >> $LOG_PATH/log.txt
        stop_test
        exit 1
    else
        #Выводим сообщение об успешной установке прав
        echo "[DEBUG] Set permissions for $number ... ok" >> $LOG_PATH/log.txt
        echo "Set permissions for $number... ok"
        PER_FLAG=1
fi
}

activate_mgm () {
    local number=$1
    local COMMAND="/domain/$DOMAIN_NAME/ss/activate $number mgm"
    $XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$COMMAND" >> /dev/null 2>>$LOG_PATH/error.log
    if test $? -ne 0; then
        echo "Error. Can't exec expect.sh (activate dvo $number)"
        echo "[ERROR] Can't exec expect.sh (activate dvo $number)" >> $LOG_PATH/log.txt
        stop_test
        exit 1
    else
        echo "[DEBUG] Activate mgm for $number... ok" >> $LOG_PATH/log.txt
        echo "Activate mgm for $number... ok"
        ACT_MGM_FLAG=1
fi
}

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
    scrn_name=`screen -list | grep -ioE "$mask"`
    for name in $scrn_name; do
        screen -S $name -X "quit" >> /dev/null 2>&1
        echo "Session $name closed"
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
            echo "[ERROR] Can't open the screen session $name" >> $LOG_PATH/log.txt
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
            echo "Bad parametr $mode"
        ;;
        esac
}

stop_test () {
    local command=""
    local number=""
    echo "[DEBUG] Stop test function activated" >> $LOG_PATH/log.txt
#    Деактивируем mgm
    if test $ACT_MGM_FLAG -ne 0; then
        echo "Deactivate MGM."
        echo "--->[DEBUG] Deactivate MGM." >> $LOG_PATH/log.txt
        for n in `seq 0 1`;do
            command="/domain/$DOMAIN_NAME/ss/deactivate ${NUMB_MASS[$n]} mgm"
            $XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$command" >> /dev/null 2>>$LOG_PATH/error.log
        done
    fi

#    Деактивация follow_me
    if test $ACT_FM_FLAG -ne 0; then
        echo "Deactivate Follow_me."
        echo "--->[DEBUG] Deactivate Follow_me." >> $LOG_PATH/log.txt
        for n in `seq 0 1`;do
            command="/domain/$DOMAIN_NAME/ss/deactivate ${NUMB_MASS[$n]} follow_me"
            $XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$command" >> /dev/null 2>>$LOG_PATH/error.log
        done
    fi

#   Сбрасываем привелегии
    if test $PER_FLAG -ne 0;then
        echo "Drop all permissions."
        echo "--->[DEBUG] Drop all permissions." >> $LOG_PATH/log.txt
        for n in `seq 0 1`;do
            for dvo in mgm follow_me;do
                command="/domain/$DOMAIN_NAME/ss/permissions clear ${NUMB_MASS[$n]} $dvo"
                $XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$command" >> /dev/null 2>>$LOG_PATH/error.log
            done
        done
    fi

#    Сброс регистрации
    echo "Stop registration."
    echo "--->[DEBUG] Stop registration." >> $LOG_PATH/log.txt
    if test $REG_FLAG -ne 0; then
    local count=0
	while [ $count -lt ${#NUMB_MASS[*]} ]
	do
            command="/domain/$DOMAIN_NAME/sip/user/stop-registration ${GROUP_NAME[$count]} ${NUMB_MASS[$count]}@${USER_DOM[$count]} --force"
            $XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$command" >> /dev/null 2>>$LOG_PATH/error.log
	    ((count++))
        done
    fi

#    Удаляем временные файлы
    if test $CSV_FLAG -ne 0; then
        echo "Remove all CSV and TXT files"
        echo "--->[DEBUG] Remove all CSV and TXT files" >> $LOG_PATH/log.txt

        rm $LOG_PATH/db.csv
        rm $LOG_PATH/db_dvo.csv
        rm $LOG_PATH/ex_code.txt
    fi
}

#-----> SCRIPT

#Ставим трап
trap "stop_test; exit 1" SIGINT SIGTERM


#Создаем необходимые файлы
mkdir $LOG_PATH1/followme >> /dev/null 2>&1
create_file $LOG_PATH/log.txt
create_file $LOG_PATH/error.log
create_file $LOG_PATH/ex_code.txt
create_file $LOG_PATH/db.csv
create_file $LOG_PATH/db_dvo.csv
#Ставим флаг
CSV_FLAG=1

echo "Start follow me test.." >> $LOG_PATH/log.txt

#Заполение сsv файла с регистрационными данными
echo -e "SEQUENTIAL
${NUMB_MASS[0]};[authentication username=${NUMB_MASS[0]} password=${USER_PASS[0]}];${USER_DOM[0]}
${NUMB_MASS[2]};[authentication username=${NUMB_MASS[2]} password=${USER_PASS[2]}];${USER_DOM[2]}
${NUMB_MASS[1]};[authentication username=${NUMB_MASS[1]} password=${USER_PASS[1]}];${USER_DOM[1]}" > $LOG_PATH/db.csv
echo "[DEBUG] $LOG_PATH/db.csv fill successfully" >> $LOG_PATH/log.txt
echo "File $LOG_PATH/db.csv fill successfully."

#Заполение csv файла кодами.
if [$PRIZN eq 0]; then 
echo -e "SEQUENTIAL
${NUMB_MASS[0]};*$KOD_SS#;[authentication username=${NUMB_MASS[0]} password=$USER_PASS];${USER_DOM[0]};
${NUMB_MASS[2]};${NUMB_MASS[0]};[authentication username=${NUMB_MASS[2]} password=${USER_PASS[2]}];${USER_DOM[2]};${USER_DOM[0]};
${NUMB_MASS[0]};#$KOD_SS#;[authentication username=${NUMB_MASS[0]} password=${USER_PASS[0]}];${USER_DOM[0]};
${NUMB_MASS[1]};#$KOD_SS**${NUMB_MASS[0]}#;[authentication username=${NUMB_MASS[1]} password=${USER_PASS[1]}];${USER_DOM[1]};
${NUMB_MASS[2]};${NUMB_MASS[0]};[authentication username=${NUMB_MASS[2]} password=${USER_PASS[2]}];${USER_DOM[2]};${USER_DOM[0]};
${NUMB_MASS[1]};*$KOD_SS**${NUMB_MASS[0]}#;[authentication username=${NUMB_MASS[1]} password=${USER_PASS[1]}];${USER_DOM[1]};" > $LOG_PATH/db_dvo.csv
echo "[DEBUG] $LOG_PATH/db_dvo.csv fill successfully." >> $LOG_PATH/log.txt
echo "File $LOG_PATH/db_dvo.csv fill successfully"
else 
echo -e "SEQUENTIAL
${NUMB_MASS[0]};*$KOD_SS*$USER_PIN#;[authentication username=${NUMB_MASS[0]} password=$USER_PASS];${USER_DOM[0]};
${NUMB_MASS[2]};${NUMB_MASS[0]};[authentication username=${NUMB_MASS[2]} password=${USER_PASS[2]}];${USER_DOM[2]};${USER_DOM[0]};
${NUMB_MASS[0]};#$KOD_SS#;[authentication username=${NUMB_MASS[0]} password=${USER_PASS[0]}];${USER_DOM[0]};
${NUMB_MASS[1]};#$KOD_SS*$USER_PIN*${NUMB_MASS[0]}#;[authentication username=${NUMB_MASS[1]} password=${USER_PASS[1]}];${USER_DOM[1]};
${NUMB_MASS[2]};${NUMB_MASS[0]};[authentication username=${NUMB_MASS[2]} password=${USER_PASS[2]}];${USER_DOM[2]};${USER_DOM[0]};
${NUMB_MASS[1]};*$KOD_SS*$USER_PIN*${NUMB_MASS[0]}#;[authentication username=${NUMB_MASS[1]} password=${USER_PASS[1]}];${USER_DOM[1]};" > $LOG_PATH/db_dvo.csv
echo "[DEBUG] $LOG_PATH/db_dvo.csv fill successfully." >> $LOG_PATH/log.txt
echo "File $LOG_PATH/db_dvo.csv fill successfully"
fi

#Настройка SSW
echo "[DEBUG] Trying to set permissions and activate mgm" >> $LOG_PATH/log.txt
echo "Trying to set permissions and activate mgm"
#Устанавливаем права
set_permissions "${NUMB_MASS[1]}"
set_permissions "${NUMB_MASS[0]}"
#Активируем услугу
activate_mgm "${NUMB_MASS[1]}"
activate_mgm "${NUMB_MASS[0]}"

echo "Trying to register users..."
echo "[DEBUG] Trying to register users..." >> $LOG_PATH/log.txt
#Регистрация абонентов
COUNT=0
while [ $COUNT -lt ${#PORT_MASS[*]} ]
do
#    Так как не получилось настроить мультипорт. Каруселим данные в файле db.csv
#    Читаем последнюю строку
    LAST_STRING=`tail -1 $LOG_PATH/db.csv`
#   Запускаем скрипт регистрации
    $SIPP_PATH/sipp  -sf $XML_PATH/uac_reg.xml  -inf $LOG_PATH/db.csv $EXT_IP -i $LOC_IP -m 1 -p ${PORT_MASS[$COUNT]} -recv_timeout 200s -timeout_error # > /dev/null 2>$LOG_PATH/error.log
#   Проверяем exit code
    if test $? -ne 0
    then
        echo "Error. See $LOG_PATH/log.txt"
        echo "[ERROR] Registration ${NUMB_MASS[$COUNT]} failed! Aborting" >> $LOG_PATH/log.txt
        #stop_test
        exit 1
    else
        echo "[DEBUG] Registration ${NUMB_MASS[$COUNT]}... ok" >> $LOG_PATH/log.txt
        REG_FLAG=1
    fi
#    Удаляем последнюю строку
    sed -i '$d' $LOG_PATH/db.csv
#    Добавляем последнюю строку на место первой.
    sed -i "2i ${LAST_STRING}" $LOG_PATH/db.csv
    (( COUNT++ ))
done
echo "Registration successful."
echo "[DEBUG] Registration successful." >> $LOG_PATH/log.txt

#Включаем follow_me и тестируем услугу
COUNT=0
while [ $COUNT -lt ${#PORT_MASS[*]} ]
do
    #Так как не получилось настроить мультипорт. Каруселим данные в файле db.csv
    #Читаем последнюю строку
    LAST_STRING=`tail -1 $LOG_PATH/db_dvo.csv`
    if [ $COUNT -le 1 ];then
        sudo $SIPP_PATH/sipp  -sf  $XML_PATH/uac_dvo.xml -inf $LOG_PATH/db_dvo.csv $EXT_IP -i $LOC_IP -m 1 -p ${PORT_MASS[$COUNT]} -recv_timeout 100s -timeout_error #2>$LOG_PATH/error.log
    if test $? -ne 0; then
        echo "Error. Can't activate follow_me"
        echo "[ERROR] Can't activate follow_me" >> $LOG_PATH/log.txt
        stop_test
        result "fail"
        exit 1
    else
        result "succ"
    fi
    else
        ACT_FM_FLAG=1
        echo "Activation follow_me success"
        echo "[DEBUG] Activation follow_me success" >> $LOG_PATH/log.txt

        COMMAND="$SIPP_PATH/sipp -sf $XML_PATH/uas.xml $EXT_IP -i $LOC_IP -m 1 -p ${PORT_MASS[$COUNT-1]} -recv_timeout 20s -timeout 30s -timeout_error 2>>$LOG_PATH/error.log; echo UAS WITHOUT_100REL EX_CODE \$? >> $LOG_PATH/ex_code.txt"
        start_screen "UAS_WOUT_100rel" "$COMMAND"
        echo "Trying to open screen session for UAS"&
        echo "[DEBUG] Trying to open screen session for UAS" >> $LOG_PATH/log.txt&
#       Даем screen сессии подняться
        sleep 0.5
        check_screen "open" "UAS_WOUT_100rel"
        if test $? -ne 0; then
            result "fail"
        else
            echo "[DEBUG] Trying to call a number with follow_me" >> $LOG_PATH/log.txt&
            sudo $SIPP_PATH/sipp  -sf $XML_PATH/uac.xml -inf $LOG_PATH/db_dvo.csv $EXT_IP -i $LOC_IP -m 1 -p ${PORT_MASS[$COUNT]} -recv_timeout 30s -timeout_error 2>$LOG_PATH/error.log
            if test $? -ne 0; then
#               Если звонок не прошел необходимо подождать завершения screeen по timeout
                echo "[ERROR] Test call to number with follow_me failed." >> $LOG_PATH/log.txt
                echo "Error. Test call to number with follow_me failed."
                result "fail"
                wait_uas "UAS_WOUT_100rel"
            else
                result "succ"
                echo "[DEBUG] Test call to number with follow_me success." >> $LOG_PATH/log.txt
            fi
        fi
#       Делаем паузу между тестами

        sleep 2s

        COMMAND="$SIPP_PATH/sipp -sf $XML_PATH/sdp/uas.xml $EXT_IP -i $LOC_IP -m 1 -p ${PORT_MASS[$COUNT-1]} -recv_timeout 10s -timeout 30s -timeout_error 2>>$LOG_PATH/error.log; echo UAS WITH_100REL EX_CODE \$? >> $LOG_PATH/ex_code.txt"
        echo "[DEBUG] Trying to open screen session for UAS (100rel)" >> $LOG_PATH/log.txt&
        start_screen "UAS_WITH_100rel" "$COMMAND"
        sleep 0.5
        check_screen "open" "UAS_WITH_100rel"
        if test $? -ne 0; then
            result "fail"
        else
            echo "[DEBUG] Trying to call a number with follow_me (100rel)" >> $LOG_PATH/log.txt&
            sudo $SIPP_PATH/sipp  -sf $XML_PATH/sdp/uac.xml -inf $LOG_PATH/db_dvo.csv $EXT_IP -i $LOC_IP -m 1 -p ${PORT_MASS[$COUNT]} -recv_timeout 30s -timeout_error 2>$LOG_PATH/error.log
            if test $? -ne 0; then
#               Если звонок не прошел необходимо подождать завершения screeen по timeout
                result "fail"
                echo "[ERROR] Test call to number with follow_me failed (100rel)." >> $LOG_PATH/log.txt
                echo "Error. Test call to number with follow_me failed (100rel)."
                wait_uas "UAS_WITH_100rel"
            else
                echo "[DEBUG] Test call to number with follow_me success (100rel)." >> $LOG_PATH/log.txt
                result "succ"
            fi
        fi
    fi
    #Удаляем последнюю строку
    sed -i '$d' $LOG_PATH/db_dvo.csv
    #Добавляем последнюю строку на место первой.
    sudo sed -i "2i ${LAST_STRING}" $LOG_PATH/db_dvo.csv
    ((COUNT++))
done
sleep 1s
#Удаляем ДВО, делаем тестовый звонок
COUNT=0
#Изменяем местами первый и второй элемент массива PORT_MASS местами
#Делаем это потому что вначале удалённый телефон отключает услугу, а после локальныйf
I=${PORT_MASS[1]}
PORT_MASS[1]=${PORT_MASS[0]}
PORT_MASS[0]=$I

while [ $COUNT -lt ${#PORT_MASS[*]} ]
do
    #Так как не получилось настроить мультипорт. Каруселим данные в файле db.csv
    #Читаем последнюю строку
    LAST_STRING=`tail -1 $LOG_PATH/db_dvo.csv`
    if [ $COUNT -le 1 ];then
        sudo $SIPP_PATH/sipp -sf  $XML_PATH/uac_dvo.xml -inf $LOG_PATH/db_dvo.csv $EXT_IP -i $LOC_IP -m 1 -p ${PORT_MASS[$COUNT]} -recv_timeout 100s -timeout_error 2>>$LOG_PATH/error.log
        if test $? -ne 0; then
            echo "Error. Can't deactivate follow_me"
            echo "[ERROR] Can't deactivate follow_me" >> $LOG_PATH/log.txt
            result "fail"
            stop_test
            exit 1
        else
            result "succ"
        fi
    else
        ACT_FM_FLAG=0
        echo "Deactivation follow_me success"
        echo "[DEBUG] Deactivation follow_me success" >> $LOG_PATH/log.txt

        COMMAND="$SIPP_PATH/sipp -sf $XML_PATH/uas.xml $EXT_IP -i $LOC_IP -m 1 -p ${PORT_MASS[$COUNT-1]} -recv_timeout 20s -timeout 60s -timeout_error 2>>$LOG_PATH/error.log; echo UAS WITHOUT_100REL EX_CODE \$? >> $LOG_PATH/ex_code.txt"
        start_screen "UAS_WOUT_100rel" "$COMMAND"
        echo "Trying to open screen session for UAS"&
        echo "[DEBUG] Trying to open screen session for UAS" >> $LOG_PATH/log.txt&
#       Даем screen сессии подняться
        sleep 0.5
        check_screen "open" "UAS_WOUT_100rel"
        if test $? -ne 0; then
            result "fail"
        else
            echo "[DEBUG] Trying test call" >> $LOG_PATH/log.txt&
            sudo $SIPP_PATH/sipp  -sf $XML_PATH/uac.xml -inf $LOG_PATH/db_dvo.csv $EXT_IP -i $LOC_IP -m 1 -p ${PORT_MASS[$COUNT]} -recv_timeout 30s -timeout_error 2>>$LOG_PATH/error.log
            if test $? -ne 0; then
                result "fail"
#               Если звонок не прошел необходимо подождать завершения screeen по timeout
                echo "[ERROR] Test call failed." >> $LOG_PATH/log.txt
                echo "Error. Test call failed."
                wait_uas "UAS_WOUT_100rel"
            else
                result "succ"
                echo "[DEBUG] Test call success." >> $LOG_PATH/log.txt
            fi
        fi
#       Делаем паузу между тестами
        sleep 2s
        COMMAND="$SIPP_PATH/sipp -sf $XML_PATH/sdp/uas.xml $EXT_IP -i $LOC_IP -m 1 -p ${PORT_MASS[$COUNT-1]} -recv_timeout 10s -timeout 60s -timeout_error 2>>$LOG_PATH/error.log 2>>$LOG_PATH/error.log; echo UAS WITH_100REL EX_CODE \$? >> $LOG_PATH/ex_code.txt"
        echo "[DEBUG] Trying to open screen session for UAS (100rel)" >> $LOG_PATH/log.txt&
        start_screen "UAS_WITH_100rel" "$COMMAND"
        sleep 0.5
        check_screen "open" "UAS_WITH_100rel"
        if test $? -ne 0; then
            result "fail"
        else
            echo "[DEBUG] Trying test call (100rel)" >> $LOG_PATH/log.txt&
            sudo $SIPP_PATH/sipp  -sf $XML_PATH/sdp/uac.xml -inf $LOG_PATH/db_dvo.csv $EXT_IP -i $LOC_IP -m 1 -p ${PORT_MASS[$COUNT]} -recv_timeout 30s -timeout_error 2>>$LOG_PATH/error.log
            if test $? -ne 0; then
                result "fail"
                echo "[ERROR] Test call failed (100rel)." >> $LOG_PATH/log.txt
                echo "Error. Test call failed (100rel)."
                wait_uas "UAS_WITH_100rel"
            else
                echo "[DEBUG] Test call success (100rel)." >> $LOG_PATH/log.txt
                result "succ"
            fi
        fi
    fi
    #Удаляем последнюю строку
    sed -i '$d' $LOG_PATH/db_dvo.csv
    #Добавляем последнюю строку на место первой.
    sudo sed -i "2i ${LAST_STRING}" $LOG_PATH/db_dvo.csv
    (( COUNT++ ))
done

#Заводим таймер
timer=0
echo "Waiting. Read ex_code.txt"
echo "[DEBUG] Read ex_code from UAS" >> $LOG_PATH/log.txt
while true;do
num_of_rows=`cat $LOG_PATH/ex_code.txt | wc -l`
    if test $num_of_rows -eq 4;then
        break
    fi
    if test $timer -eq 150; then
        echo "Error. Can't recive ex_code from UAS. Timeout"
        echo "[ERROR] Error. Can't recive ex_code from UAS. Timeout" >> $LOG_PATH/log.txt
        stop_screen "UAS[_,a-Z,0-9]+"
        echo "Error. Test failed! Aborting."
        stop_test
        exit 1
    fi
    ((timer++))
    sleep 1
done

#    Читаем exit коды, чтобы убедиться, что все UAS отработали корректно.
pointer=0
while read line;do
     excode=`echo $line | cut -d ' ' -f 4`
     name=`echo $line | cut -d ' ' -f 1`
     echo "--->[DEBUG] Exit code from $name equal $excode" >> $LOG_PATH/log.txt
     if [ "$excode" != "0" ];then
          pointer=1
     fi
done < $LOG_PATH/ex_code.txt

if [[ $pointer -eq 0 && $FAIL_COUNT -eq 0 ]];then
    stop_test
    echo "Test success. Success calls: $SUCC_COUNT, Failed Calls: $FAIL_COUNT"
    echo "Test success. Success calls: $SUCC_COUNT, Failed Calls: $FAIL_COUNT" >> $LOG_PATH/log.txt
    echo "Aleksandr Romanov | follow_me | Success calls: $SUCC_COUNT | Failed Calls: $FAIL_COUNT | EX_CODE 0" > /dev/udp/$SERVICE_IP/1223
    exit 0
else
    stop_test
    echo "Test failed. $SUCC_COUNT, Failed Calls: $FAIL_COUNT"
    echo "Test failed. $SUCC_COUNT, Failed Calls: $FAIL_COUNT"  >> $LOG_PATH/log.txt
    echo "Aleksandr Romanov | follow_me | Success calls: $SUCC_COUNT | Failed Calls: $FAIL_COUNT | EX_CODE 1" > /dev/udp/$SERVICE_IP/1223
    exit 1
fi

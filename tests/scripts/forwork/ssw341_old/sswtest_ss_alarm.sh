#!/bin/bash

#Alarm call
#Проверка разового будильника.
#Читаем текущее время

#PATH
SIPP_PATH="$HOME/sipp"
XML_PATH="$HOME/test/ss_alarm"
LOG_PATH="$HOME/test/temp/ssw_alarm"

# Переменные командной строки
# $1 SSW_cocon_user
# $2 SSW_cocon_password
# $3 SSW_domain   
# $4 SSW_IP_address  
# $5 SIPP_IP_address
# $6 Group of SIP USER A

#NETWORK
LOCAL_IP=$5
EXT_IP=$4
PORT=5060
#SSW_PARAM
USERNAME=$1
PASSWORD=$2
SSW_IP=$4
DOMAIN_NAME=$3

#группа в которой создан абонент
GROUP=$6
#Номер телефона на котором будем проверять будильник
NUMBER=200100
DOM=voip.local
# Переменные для подсчета успешных, неуспешных вызовов
FAIL_COUNT=0
SUCC_COUNT=0
# Переменные времени
WEEKDAY=0
HOUR=0
MIN=0
SEC=0
# Переменные для стоп функции
ACT_MGM_FLAG=0
PER_FLAG=0
CSV_FLAG=0
ACT_ALARM_FLAG=0

#Функция создания scv файла
function create_csv () {
if touch $LOG_PATH/calls.csv; then
    echo "SEQUENTIAL" > $LOG_PATH/calls.csv
    echo "[DEBUG] $LOG_PATH/calls.csv successfully created." >> $LOG_PATH/log.txt
else
    echo "Error. See $LOG_PATH/log.txt"
    echo "[ERROR] Could not create file $LOG_PATH/calls.csv! Aborting." >> $LOG_PATH/log.txt
    exit 1
fi
}

#Функция удаления csv файла
function remove_csv ()
{
sudo rm -r $LOG_PATH/calls.csv
echo "[DEBUG] All csv files are removed." >> $LOG_PATH/log.txt
}



#Функция запуска теста
function start_test()
{
#Запускаем UAC
$SIPP_PATH/sipp -sf $XML_PATH/uac.xml -inf $LOG_PATH/calls.csv $EXT_IP -i $LOCAL_IP -m 1 -p $PORT -recv_timeout 20s -timeout_error -timeout 30s
#Проверяем exit код
if test $? -ne 0
    then
        echo "[ERROR] Test $1 $2 fail." >> $LOG_PATH/log.txt
        FAIL_COUNT=$(($FAIL_COUNT+1))
        return 1
    else
        echo "[DEBUG] Alarm $1 $2." >> $LOG_PATH/log.txt
fi
ACT_ALARM_FLAG=1
#Если не обходимо только деативировать будильник выходим
if [ "$2" == "deactivate" ]
then
    SUCC_COUNT=$(($SUCC_COUNT+1))
    return 0
fi

#Запускаем UAS
sudo $SIPP_PATH/sipp -sf ${XML_PATH}${3}/uas.xml  $EXT_IP -i $LOCAL_IP -m 1 -p $PORT -recv_timeout 20s -timeout_error -timeout 130s
#Проверяем дозвонился ли будильник
if test $? -ne 0
    then
        echo "[ERROR] Test $1. No call from Alarm." >> $LOG_PATH/log.txt
        #Так как будильник активировался, но звонок не поступил или был обработан с ошибкой необходимо
        #деактивировать данный будильник
        echo "-->[DEBUG] Test $1. Try to deactivate Alarm..." >> $LOG_PATH/log.txt
        COMMAND="/domain/$DOMAIN_NAME/ss/deactivate $NUMBER alarm"
        $XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$COMMAND" >> /dev/null 2>>$LOG_PATH/errors.log
        echo "-->[DEBUG] Test $1. Alarm deactivated." >> $LOG_PATH/log.txt
        echo "-->[DEBUG] Test $1. Aborting." >> $LOG_PATH/log.txt
        FAIL_COUNT=$(($FAIL_COUNT+1))
        return 1
    else
        echo "[DEBUG] Test $1 success." >> $LOG_PATH/log.txt
fi
ACT_ALARM_FLAG=0
SUCC_COUNT=$(($SUCC_COUNT+1))
return 0
}


#Функция получения времени
function get_time ()
{
WEEKDAY=`date  +%-u`
HOUR=`date  +%-H`
MIN=`date  +%-M`
SEC=`date  +%-S`
#Собираем время
if [ $SEC -le 50 ]
        then
                if [ $MIN -eq 59 ]
                        then
                                MIN=0
                                HOUR=$((HOUR+1))
                        else
                                MIN=$((MIN+1))
                fi
        else
                if [ $MIN -eq 59 ]
                        then
                                MIN=1
                                HOUR=$((HOUR+1))
                        else
                                MIN=$((MIN+2))
                fi
        fi

}

#Функция стоп тест
stop_test () {
    echo "[DEBUG] STOP_TEST Function activated." >> $LOG_PATH/log.txt
    echo "Waiting try to stop test..."
    if test $ACT_MGM_FLAG -ne 0;then
        #Деактивируем mgm абоненту
        COMMAND="/domain/$DOMAIN_NAME/ss/deactivate $NUMBER mgm"
        $XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$COMMAND" >> /dev/null 2>>$LOG_PATH/errors.log
        #Выводим сообщение об успешной деактивации mgm
        echo "[DEBUG] Deactivate mgm... ok" >> $LOG_PATH/log.txt
    fi

    if test $ACT_ALARM_FLAG -ne 0;then
        echo "[DEBUG] Try to deactivate Alarm..." >> $LOG_PATH/log.txt
        COMMAND="/domain/$DOMAIN_NAME/ss/deactivate $NUMBER alarm"
        $XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$COMMAND" >> /dev/null 2>>$LOG_PATH/errors.log
        echo "[DEBUG] Alarm deactivated." >> $LOG_PATH/log.txt

    fi
    if test $PER_FLAG -ne 0;then
        #Чистим права
        COMMAND="/domain/$DOMAIN_NAME/ss/permissions clear $NUMBER alarm"
        $XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$COMMAND" >> /dev/null 2>>$LOG_PATH/errors.log
        COMMAND="/domain/$DOMAIN_NAME/ss/permissions clear $NUMBER mgm"
        $XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$COMMAND" >> /dev/null 2>>$LOG_PATH/errors.log
        #Выводим сообщение об успешной очистке прав
        echo "[DEBUG] Drop permissions... ok" >> $LOG_PATH/log.txt
    fi

    if test $CSV_FLAG -ne 0;then
        remove_csv
    fi
}

#-----> SCRIPT
trap "stop_test; exit 1" SIGINT SIGTERM

#Создаем лог дир
mkdir $LOG_PATH >> /dev/null 2>&1
if test $? -eq 130; then 
    echo "Error can't create $LOG_PATH"
else
    echo "DIR $LOG_PATH successfully created"
fi
#Чистим лог и делаем заголовок
echo "Starting alarm test ..." > $LOG_PATH/log.txt
echo "Expect errors:" > $LOG_PATH/errors.log

#Выставляем права на использование услуг
COMMAND="/domain/$DOMAIN_NAME/ss/permissions change $NUMBER --enable --unlock alarm mgm"
#Конфигурируем SSW
$XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$COMMAND" >> /dev/null 2>>$LOG_PATH/errors.log
if test $? -ne 0; then
    echo "Error. Can't exec expect.sh (set perm)"
    echo "[ERROR] Can't exec expect.sh (set perm)" >> $LOG_PATH/log.txt
    stop_test
    exit 1
else
    #Выводим сообщение об успешной установке прав
    echo "[DEBUG] Set permissions... ok" >> $LOG_PATH/log.txt
    echo "Set permissions... ok"
    PER_FLAG=1
fi


#Активируем mgm абоненту
COMMAND="/domain/$DOMAIN_NAME/ss/activate $NUMBER mgm"
$XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$COMMAND" >> /dev/null 2>>$LOG_PATH/errors.log
if test $? -ne 0; then
    echo "Error. Can't exec expect.sh (activete dvo)"
    echo "[ERROR] Can't exec expect.sh (activete dbo)" >> $LOG_PATH/log.txt
    stop_test
    exit 1
else
    echo "[DEBUG] Activate mgm... ok" >> $LOG_PATH/log.txt
    echo "Activate mgm... ok"
    ACT_MGM_FLAG=1
fi

#Создаем csv
create_csv
CSV_FLAG=1

#ТЕСТ ПЕРВЫЙ Проверка разового будильника на ближайшие 24 часа Пишем в лог о начале теста
echo "[DEBUG] =====TEST 1 START=====" >> $LOG_PATH/log.txt
echo "[DEBUG] Trying without 100rel:" >> $LOG_PATH/log.txt

#Забираем время
get_time
#Собираем строку для подключения услуги абоненту
CSV_STRING=`printf "$NUMBER;*55*1*%02.0f%02.0f#;[authentication username=$NUMBER password=$NUMBER];$DOM" "$HOUR" "$MIN"`
#Добавляем собранную строку в конец файла
sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
#Запускаем тест
start_test "One-time" "activate"
#Удаляем последнюю строку
sudo sed -i '$d' $LOG_PATH/calls.csv


#Тест c PRACK
#Пишем лог
echo "[DEBUG] Trying with 100rel:" >> $LOG_PATH/log.txt
#Забираем время
get_time
#Собираем строку для подключения услуги абоненту
CSV_STRING=`printf "$NUMBER;*55*1*%02.0f%02.0f#;[authentication username=$NUMBER password=$NUMBER];$DOM" "$HOUR" "$MIN"`
#Добавляем собранную строку в конец файла
sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
#Запускаем тест
start_test "One-time" "activate" "/sdp"
#Удаляем последнюю строку
sudo sed -i '$d' $LOG_PATH/calls.csv

#ТЕСТ 2
#Проверка разового будильника на сегоднешний день недели  * 55 * НОМЕР_БУДИЛЬНИКА * ДЕНЬ_НЕДЕЛИ * ЧЧММ #
#Пишем в лог о начале теста
echo "[DEBUG] =====TEST 2 START=====" >> $LOG_PATH/log.txt
echo "[DEBUG] Trying without 100rel:" >> $LOG_PATH/log.txt
#Забираем время
get_time
#Собираем строку для подключения услуги абоненту
CSV_STRING=`printf "$NUMBER;*55*1*%01.0f*%02.0f%02.0f#;[authentication username=$NUMBER password=$NUMBER];$DOM" "$WEEKDAY" "$HOUR" "$MIN"`
sudo sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
#Запускаем тест
start_test "One-time on weekday" "activate"
#Удаляем последнюю строку.
sudo sed -i '$d' $LOG_PATH/calls.csv

echo "[DEBUG] Trying with 100rel:" >> $LOG_PATH/log.txt
#Забираем время
get_time
#Собираем строку для подключения услуги абоненту
CSV_STRING=`printf "$NUMBER;*55*1*%01.0f*%02.0f%02.0f#;[authentication username=$NUMBER password=$NUMBER];$DOM" "$WEEKDAY" "$HOUR" "$MIN"`
sudo sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
#Запускаем тест
start_test "One-time on weekday" "activate" "/sdp"
#Удаляем последнюю строку.
sudo sed -i '$d' $LOG_PATH/calls.csv


#ТЕСТ 3
#Проверка ежедневного будильника * 56 * НОМЕР_БУДИЛЬНИКА * ДНИ_НЕДЕЛИ * ЧЧММ #
#Пишем в лог о начале теста
echo "[DEBUG] =====TEST 3 START=====" >> $LOG_PATH/log.txt
echo "[DEBUG] Trying without 100rel:" >> $LOG_PATH/log.txt
get_time
#Собираем строку для подключения услуги абоненту
CSV_STRING=`printf "$NUMBER;*56*1*%02.0f%02.0f#;[authentication username=$NUMBER password=$NUMBER];$DOM" "$HOUR" "$MIN"`
#Добавляем  сторку в csv
sudo sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
start_test "Daily" "activate"
REZULT=$?
#Удаляем полседнюю строку.
sudo sed -i '$d' $LOG_PATH/calls.csv
#Если активация услуги прошла не успешно то нет смысла её пытаться деактивировать
if test $REZULT -eq 0
then
    ##Деактивация ежедневного будильника #55*<НОМЕР_БУДИЛЬНИКА>#
    #Формируем строку для отключения будильника
    CSV_STRING="$NUMBER;#55*1#;[authentication username=$NUMBER password=$NUMBER];$DOM"
    #Добавляем  сторку в csv
    sudo sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
    #Отключаем будильник
    start_test "Daily" "deactivate"
    #Удаляем полседнюю строку.
    sudo sed -i '$d' $LOG_PATH/calls.csv
fi

echo "[DEBUG] Trying with 100rel:" >> $LOG_PATH/log.txt
get_time
#Собираем строку для подключения услуги абоненту
CSV_STRING=`printf "$NUMBER;*56*1*%02.0f%02.0f#;[authentication username=$NUMBER password=$NUMBER];$DOM" "$HOUR" "$MIN"`
#Добавляем  сторку в csv
sudo sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
start_test "Daily" "activate" "/sdp"
REZULT=$?
#Удаляем полседнюю строку.
sudo sed -i '$d' $LOG_PATH/calls.csv
#Если активация услуги прошла не успешно то нет смысла её пытаться деактивировать
if test $REZULT -eq 0
then
    ##Деактивация ежедневного будильника #55*<НОМЕР_БУДИЛЬНИКА>#
    #Формируем строку для отключения будильника
    CSV_STRING="$NUMBER;#55*1#;[authentication username=$NUMBER password=$NUMBER];$DOM"
    #Добавляем  сторку в csv
    sudo sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
    #Отключаем будильник
    start_test "Daily" "deactivate" "/sdp"
    #Удаляем полседнюю строку.
    sudo sed -i '$d' $LOG_PATH/calls.csv
fi
#ТЕСТ 4
#Проверка ежедневного будильника на определенные дни недели * 56 * НОМЕР_БУДИЛЬНИКА * ДНИ_НЕДЕЛИ * ЧЧММ #
#Пишем в лог о начале теста
echo "[DEBUG] =====TEST 4 START=====" >> $LOG_PATH/log.txt
echo "[DEBUG] Trying without 100rel:" >> $LOG_PATH/log.txt
get_time
#Добавим к нашему weekday ещё парочку дней недели
#Проверка на кол-во дней недели
if [ $WEEKDAY -le 5 ]
    then
        WEEKDAYS=$((WEEKDAY))$((WEEKDAY+1))$((WEEKDAY+2))
    else
        WEEKDAYS=$((WEEKDAY-2))$((WEEKDAY-1))$((WEEKDAY))
    fi

#Собираем строку для подключения услуги абоненту
CSV_STRING=`printf "$NUMBER;*56*2*%03.0f*%02.0f%02.0f#;[authentication username=$NUMBER password=$NUMBER];$DOM" "$WEEKDAYS" "$HOUR" "$MIN"`
sudo sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
start_test "Daily on weekdays" "activate"
REZULT=$?
#Удаляем полседнюю строку.
sudo sed -i '$d' $LOG_PATH/calls.csv

if test $REZULT -eq 0
then
    ##Деактивация всех будильников #55*0#
    #Формируем строку для отключения будильника
    CSV_STRING="$NUMBER;#55*0#;[authentication username=$NUMBER password=$NUMBER];$DOM"
    #Добавляем  сторку в csv
    sudo sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
    #Отключаем будильник
    start_test "Daily on weekdays" "deactivate"
    #Удаляем полседнюю строку.
    sudo sed -i '$d' $LOG_PATH/calls.csv
fi

echo "[DEBUG] Trying with 100rel:" >> $LOG_PATH/log.txt
get_time
#Собираем строку для подключения услуги абоненту
CSV_STRING=`printf "$NUMBER;*56*2*%03.0f*%02.0f%02.0f#;[authentication username=$NUMBER password=$NUMBER];$DOM" "$WEEKDAYS" "$HOUR" "$MIN"`
sudo sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
start_test "Daily on weekdays" "activate" "/sdp"
REZULT=$?
#Удаляем полседнюю строку.
sudo sed -i '$d' $LOG_PATH/calls.csv

if test $REZULT -eq 0
then
    ##Деактивация всех будильников #55*0#
    #Формируем строку для отключения будильника
    CSV_STRING="$NUMBER;#55*0#;[authentication username=$NUMBER password=$NUMBER];$DOM"
    #Добавляем  сторку в csv
    sudo sed -i "$ a ${CSV_STRING}" $LOG_PATH/calls.csv
    #Отключаем будильник
    start_test "Daily on weekdays" "deactivate"
    #Удаляем полседнюю строку.
    sudo sed -i '$d' $LOG_PATH/calls.csv
fi


#Выводим результат в консоль
echo "Success $SUCC_COUNT, Failed $FAIL_COUNT"
echo "For more information see $LOG_PATH/log.txt"

#Обнуляем регистрацию
COMMAND="/domain/$DOMAIN_NAME/sip/user/stop-registration $GROUP $NUMBER@$EXT_IP --force"
#Конфигурируем SSW
$XML_PATH/expect.sh $USERNAME $PASSWORD $SSW_IP "$COMMAND" >> /dev/null 2>>$LOG_PATH/errors.log
echo "[DEBUG] Stop registrtion... ok" >> $LOG_PATH/log.txt
#Даём exit code
if test $FAIL_COUNT -ne 0
    then
        stop_test
        echo "[ERROR] Test Alarm failed!" >> $LOG_PATH/log.txt
            exit 1
    else
        stop_test
        echo "[DEBUG] Test Alarm success!" >> $LOG_PATH/log.txt
        exit 0
fi

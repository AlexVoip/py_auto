#!/bin/bash

if [ $# -ne 9 ]
then
	echo -e  "\nОшибка при запуске\n"

elif [ $# -eq 9 ]
then

touch /$3/cfg.yaml				 #создадим пустой файл в папке tftp-сервера
sudo chmod o+rwx /$3/cfg.yaml 			 #присвоим права


#сброс к завод.настройкам

java -jar $9 -htmlsuite "*firefox" "http://$1" "TESTS/sbc/Selenium/restore(suite).html" "TESTS/sbc/Selenium/result(restore).html"

#for (( i=100; i>0; i--)); do
# sleep 1 &
#  printf "Идет перезагрузка SBC: $i \r"
#  wait
#done

#восстанавливаем IP адрес

sleep 2
sudo ifconfig $5 $8

(
        sleep 1
        echo "admin"
        sleep 1
        echo "rootpasswd"
        sleep 1
        echo "sh"
        sleep 1
        echo "ifconfig $6 $1"
	sleep 2
                ) | telnet $2

sudo ifconfig $5 $7

#ввод контрольных параметров через Selenium
java -jar $9 -htmlsuite "*firefox" "http://$1" "TESTS/sbc/Selenium/control_param(suite).html" "TESTS/sbc/Selenium/result.html"

sleep 2
cd TESTS/sbc/
sleep 1

(
	sleep 1
	echo "admin"
	sleep 1
	echo "rootpasswd"
	sleep 1
	echo "sh"
	sleep 1
	echo "cd /etc/config/"
	sleep 1
	echo "tftp -pl cfg.yaml $4"
	sleep 1
		) | telnet $1		#скачиваем новые внесенные конфигурации

(
	sleep 2
	echo "get cfg.yaml"
	echo "quit"
		) | tftp $4		#адрес tftp сервера
sleep3

#сравнение строк
file1=cfg.yaml
file2=control_file
 
str1=$(cat $file1)
str2=$(cat $file2)

        if [ "$str1" = "$str2" ]
        then
                echo -e "\n#############\nОтличий нет\nЭто победа\n#############"
        else
                echo -e "\n###################\n  Имеются отличия\n###################"
                echo "Разница: контрольный/считанный"
                diff  $file1 $file2
	fi
fi

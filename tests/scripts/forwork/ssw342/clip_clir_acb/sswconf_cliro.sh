#!/usr/bin/expect -f

# Конфигурирование SSW для ДВО. Версия ПО 3.3.
set user [lindex $argv 0]
set pass [lindex $argv 1]
set dom_name [lindex $argv 2]
set host [lindex $argv 3]
set number [lindex $argv 4]

spawn ssh -q -t -o StrictHostKeyChecking=no $user@$host -p 8023
expect "password:"
send "$pass\r"
expect -ex ":/$"

send "/domain/$dom_name/ss/activate $number clip mode = cliro\r"
expect -ex ":/$"
send "exit\r"
expect eof

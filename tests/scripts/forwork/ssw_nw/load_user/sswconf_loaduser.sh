#!/usr/bin/expect -f

# Конфигурирование SSW для теста базовых вызовов. Версия ПО 3.3.
set user [lindex $argv 0]
set pass [lindex $argv 1]
set dom_name [lindex $argv 2]
set host [lindex $argv 3]
set group [lindex $argv 4]
set number [lindex $argv 5]
set domain [lindex $argv 6]

spawn ssh $user@$host -p 8023
expect "password:"
send "$pass\r"
expect -ex ":/$"

send "/domain/$dom_name/sip/user/set $group $number@$domain call-limit 0\r"
expect -ex ":/$"
send "exit\r"
expect eof
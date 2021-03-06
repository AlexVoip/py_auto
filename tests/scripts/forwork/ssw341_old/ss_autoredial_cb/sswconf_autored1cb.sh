#!/usr/bin/expect -f

# Конфигурирование SSW. Версия ПО 3.3.
set user [lindex $argv 0]
set pass [lindex $argv 1]
set dom_name [lindex $argv 2]
set host [lindex $argv 3]
set number [lindex $argv 4]

spawn ssh $user@$host -p 8023
expect "password:"
send "$pass\r"
expect -ex ":/$"

send "/domain/$dom_name/ss/activate $number auto_redial_with_callback\r"
expect -ex ":/$"
send "exit\r"
expect eof
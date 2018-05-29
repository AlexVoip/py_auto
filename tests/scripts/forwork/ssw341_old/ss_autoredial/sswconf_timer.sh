#!/usr/bin/expect -f

# Конфигурирование SSW для теста базовых вызовов. Версия ПО 3.3.
set user [lindex $argv 0]
set pass [lindex $argv 1]
set dom_name [lindex $argv 2]
set host [lindex $argv 3]

spawn ssh $user@$host -p 8023
expect "password:"
send "$pass\r"
expect -ex ":/$"

send "/domain/$dom_name/core/obcsm/set o_no_answer_timeout 90\r"
expect -ex ":/$"
send "/domain/$dom_name/core/tbcsm/set t_no_answer_timeout 90\r"
expect -ex ":/$"
send "exit\r"
expect eof
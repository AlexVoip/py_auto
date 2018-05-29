#!/usr/bin/expect -f

# Конфигурирование SSW для теста базовых вызовов. Версия ПО 3.3.
set user [lindex $argv 0]
set pass [lindex $argv 1]
set dom_name [lindex $argv 2]
set host [lindex $argv 3]

spawn ssh -q -t -o StrictHostKeyChecking=no $user@$host -p 8023
expect "password:"
send "$pass\r"
expect -ex ":/$"

send "/domain/$dom_name/properties/timers/set no_answer_timeout 1000\r"
expect -ex ":/$"
send "/domain/$dom_name/properties/timers/set o_no_answer_timeout 1000\r"
expect -ex ":/$"
send "/domain/$dom_name/properties/timers/set conversation_timeout 10000\r"
expect -ex ":/$"
send "exit\r"
expect eof


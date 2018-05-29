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

send "/domain/$dom_name/sip/timer/set sip_T1 500\r"
expect -ex ":/$"
send "/domain/$dom_name/sip/timer/set sip_T2 4000\r"
expect -ex ":/$"
send "/domain/$dom_name/sip/timer/set sip_T4 5000\r"
expect -ex ":/$"
send "/domain/$dom_name/sip/properties/set silent_mode false\r"
expect -ex ":/$"
send "/domain/$dom_name/properties/timers/set no_answer_timeout 90\r"
expect -ex ":/$"
send "/domain/$dom_name/properties/timers/set o_no_answer_timeout 90\r"
expect -ex ":/$"
send "/domain/$dom_name/properties/timers/set conversation_timeout 100\r"
expect -ex ":/$"
send "exit\r"
expect eof

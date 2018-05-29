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

send "/domain/$dom_name/ss/permissions change * --unlock --enable mgm 3way alarm acb auto_redial auto_redial_with_callback call_recording callback cfb cfnr cfnr_type2 cfos cft cfu cfu_type2 cgg chold chunt_cycle chunt_group chunt_group chunt_manual chunt_serial clip clir ctr cw direct_call dnd follow_me mcid my_number pickup rbp redial rfc speed_dial sca sco_black sco_white scr  teleconference_manager\r"
expect -ex "?>"
send "yes\r"
expect -ex ":/$"
send "exit\r"
expect eof
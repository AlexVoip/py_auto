#!/usr/bin/expect -f

# Конфигурирование SSW

set host [lindex $argv 0]
set user [lindex $argv 1]
set pass [lindex $argv 2]

set dom_B [lindex $argv 3]
set dom_C [lindex $argv 4]
set dom_D [lindex $argv 5]
set dom_E [lindex $argv 6]

set num_B [lindex $argv 7]
set num_C [lindex $argv 8]
set num_D [lindex $argv 9]
set num_E [lindex $argv 10]

spawn ssh -q -t -o StrictHostKeyChecking=no $user@$host -p 8023

expect "password:"
send "$pass\r"
expect -ex ":/$"

send "/domain/$dom_E/ss/deactivate $num_E pickup\r"
expect -ex ":/$"
send "/domain/$dom_D/ss/deactivate $num_D pickup\r"
expect -ex ":/$"
send "/domain/$dom_C/ss/deactivate $num_C pickup\r"
expect -ex ":/$"
send "/domain/$dom_B/ss/deactivate $num_B pickup\r"
expect -ex ":/$"

send "exit\r"
expect eof

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

spawn ssh $user@$host -p 8023

expect "password:"
send "$pass\r"
expect -ex ":/$"

send "/domain/$dom_E/ss/activate $num_E pickup pickup_groups = \[lo/1\]\r"
expect -ex ":/$"
send "/domain/$dom_D/ss/activate $num_D pickup pickup_groups = \[lo/1\]\r"
expect -ex ":/$"
send "/domain/$dom_C/ss/activate $num_C pickup pickup_groups = \[hi/2\]\r"
expect -ex ":/$"
send "/domain/$dom_B/ss/activate $num_B pickup pickup_groups = \[hi/2\]\r"
expect -ex ":/$"

send "exit\r"
expect eof

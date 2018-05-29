#!/usr/bin/expect -f

# Конфигурирование SSW. Версия ПО 3.3.
set user [lindex $argv 0]
set pass [lindex $argv 1]
set dom_name [lindex $argv 2]
set host [lindex $argv 3]
set numbera [lindex $argv 4]
set numberb [lindex $argv 5]
set numberc [lindex $argv 6]
set numberd [lindex $argv 7]

spawn ssh $user@$host -p 8023
expect "password:"
send "$pass\r"
expect -ex ":/$"

send "/domain/$dom_name/ss/activate $numbera pickup pickup_groups = \[lo/1\]\r"
expect -ex ":/$"
send "/domain/$dom_name/ss/activate $numberb pickup pickup_groups = \[lo/1, hi/2\]\r"
expect -ex ":/$"
send "/domain/$dom_name/ss/activate $numberc pickup pickup_groups = \[lo/1\]\r"
expect -ex ":/$"
send "/domain/$dom_name/ss/activate $numberd pickup pickup_groups = \[hi/2\]\r"
expect -ex ":/$"
send "exit\r"
expect eof
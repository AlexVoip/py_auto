#!/usr/bin/expect -f
set USERNAME [lindex $argv 0]
set PASSWORD [lindex $argv 1]
set SSW_IP [lindex $argv 2]
set COMMAND [lindex $argv 3]

spawn ssh ${USERNAME}@${SSW_IP} -p 8023
#expect "*?yes/no*"
#send "yes\r"
expect "*?assword:*"
send   "$PASSWORD\r"
expect "*?$*"
send   "$COMMAND\r"
expect "*?$*"
send   "exit\r"
expect eof

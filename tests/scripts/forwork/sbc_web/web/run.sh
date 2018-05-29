#!/bin/bash

f=TESTS/sbc/conf_for_script 

text=$(cat $f | awk '{print($1)}')
set -- $text				#разбиваем строку, после чего каждая ее часть будет доступна как $1, $2

./TESTS/sbc/web/TESTsbc.sh $text


#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh get_rule $@

uri="threshold_rules/d99f9ed1-345c-4202-aac1-14debeed68ee"

echo "Querying..."
pdm userpane general_query $uri -s $server

echo Get Logs
pdm ftp get ps_userpane.log -u server_log -w log -s $server -p 2121 --to $working

echo "Drop existing tables"
pdm database migrate down $db_opts

echo "Recrate tables"
pdm database migrate up $db_opts

echo Analysis logs
pdm analysis get_rule $working/*.log > $result -t $now $db_opts

echo import analysis results
pdm database import $result $db_opts

echo backup the results
pdm database migrate backup $db_opts

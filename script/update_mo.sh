#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh update_mo $@

mo_key="593a3db7-bce5-4aaf-a97e-d51f3f3888b7"
params="{properties:{systemoid:'1.9.9.9.9.9.9',devicetype:'rt'}}"

echo "Update mo"
pdm userpane update_mo $mo_key $params -s $server

echo Get Logs
pdm ftp get ps_userpane.log -u server_log -w log -s $server -p 2121 --to $working
pdm ftp get se_commander.log -u engine_log -w log -s $engine -p 2121 --to $working

echo "Drop existing tables"
pdm database migrate down $db_opts

echo "Recrate tables"
pdm database migrate up $db_opts

echo Analysis logs
pdm analysis update_mo $working/*.log > $result -t $now $db_opts

echo import analysis results
pdm database import $result $db_opts

echo backup the results
pdm database migrate backup $db_opts

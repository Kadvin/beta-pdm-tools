#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh retrieve_mo $@

mo_key="c9920835-c06c-48c0-a7d6-d12c8d8cd203"

echo "Retrieve mo"
pdm userpane retrieve_mo $mo_key -s $server

echo Get Logs
pdm ftp get ps_userpane.log -u server_log -w log -s $server -p 2121 --to $working
pdm ftp get se_commander.log se_sampling.log -u engine_log -w log -s $engine -p 2121 --to $working

echo "Drop existing tables"
pdm database migrate down $db_opts

echo "Recrate tables"
pdm database migrate up $db_opts

echo Analysis logs
pdm analysis retrieve_mo $working/*.log > $result -t $now $db_opts

echo import analysis results
pdm database import $result $db_opts

echo backup the results
pdm database migrate backup $db_opts

#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh get_mo_indicator $@

mo_key="ff2c073f-f4db-4527-b579-b1de2abdb6a1"
indicator_names="cpu,mem"

echo "Get mo indicator"
pdm userpane get_indicator $mo_key $indicator_names -s $server

echo Get Logs
pdm ftp get ps_userpane.log -u server_log -w log -s $server -p 2121 --to $working
pdm ftp get se_commander.log se_sampling.log -u engine_log -w log -s $engine -p 2121 --to $working

echo "Drop existing tables"
pdm database migrate down $db_opts

echo "Recrate tables"
pdm database migrate up $db_opts

echo Analysis logs
pdm analysis get_mo_indicator $working/*.log > $result -t $now $db_opts

echo import analysis results
pdm database import $result $db_opts

echo backup the results
pdm database migrate backup $db_opts

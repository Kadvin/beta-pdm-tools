#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh ap_list_subscribe_rules $@

type='recordRule'

echo Logout...
pdm adminpane list_subscribe_rules_by_type $type -s $server

echo Get Logs
pdm ftp get ps_adminpane.log -u server_log -w log -s $server -p 2121 --to $working

echo "Drop existing tables"
pdm database migrate down $db_opts

echo "Create tables"
pdm database migrate up $db_opts

echo Analysis logs
pdm analysis ap_list_subscribe_rules $working/*.log > $result -t $now $db_opts

echo import analysis results
pdm database import $result $db_opts

echo backup analysis results
pdm database migrate backup $db_opts

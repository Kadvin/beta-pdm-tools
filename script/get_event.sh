#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh get_event $@

destination_name="NETYUZHI"

echo "Get Event..."
pdm userpane general_query up_events/$destination_name -s $server

echo Get Logs
pdm ftp get ps_userpane.log -u server_log -w log -s $server -p 2121 --to $working

echo "Drop existing tables"
pdm database migrate down $db_opts

echo "Recrate tables"
pdm database migrate up $db_opts

echo Analysis logs
pdm analysis get_event $working/*.log > $result -t $now $db_opts

echo import analysis results
pdm database import $result $db_opts

echo backup the results
pdm database migrate backup $db_opts

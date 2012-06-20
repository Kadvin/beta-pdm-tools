#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh update_threshold_rule $@

echo Retrieve rule keys...
pdm userpane list threshold_rules -f key > $factors -s $server

echo Generate templates
pdm template update_threshold_rule --sessions $total --bursts 1 < $factors > $pressure

echo 'Pressuring(Create Record) the server'
pdm pressure httperf $pressure -s $server -p 8020

echo Get Logs
pdm ftp get ps_userpane.log -u server_log -w log -s $server -p 2121 --to $working

echo "Drop existing tables"
pdm database migrate down $db_opts

echo "Recrate tables"
pdm database migrate up $db_opts

echo Analysis logs
pdm analysis update_threshold_rule $working/*.log > $result -t $now $db_opts

echo import analysis results
pdm database import $result $db_opts

echo backup the results
pdm database migrate backup $db_opts

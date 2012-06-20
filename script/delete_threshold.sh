#!/bin/sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh delete_threshold $@

echo "Retrieving rule keys..."
pdm userpane list threshold_rules -s $server -p 8020 -f key > $factors
echo "Generate template"
pdm template delete_threshold < $factors > $pressure --sessions $total --bursts 1
echo "Pressure(Delete Threshold Rules) against $server"
pdm pressure httperf $pressure -s $server -p 8020
pdm ftp get ps_userpane.log -u server_log -w log -s $server -p 2121 --to $working
pdm ftp get se_commander.log se_scheduler.log -u engine_log -w log -s $engine -p 2121 --to $working

echo "Drop existing tables"
pdm database migrate down $db_opts
echo "Create tables"
pdm database migrate up $db_opts
echo Analysis logs
pdm analysis delete_threshold $working/*.log -t $now $db_opts > $result
echo import analysis results
pdm database import $result $db_opts
echo backup analysis results
pdm database migrate backup $db_opts

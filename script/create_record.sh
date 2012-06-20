#!/bin/sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh create_record $@

echo Retrieve mo keys...
pdm userpane list mcs/NetworkDevice/mos -f mokey > $factors -s $server

echo Generate templates
pdm template create_record --sessions $total --bursts 1 < $factors > $pressure
echo 'Pressuring(Create Record) the server'
pdm pressure httperf $pressure -s $server -p 8020

pdm ftp get ps_userpane.log -u server_log -w log -s $server -p 2121 --to $working
pdm ftp get se_commander.log se_scheduler.log -u engine_log -w log -s $engine -p 2121 --to $working

echo "Drop existing tables"
pdm database migrate down $db_opts
echo "Create tables"
pdm database migrate up $db_opts
echo Analysis logs
pdm analysis create_record $working/*.log $db_opts > $result
echo import analysis results
pdm database import $result $db_opts
echo backup analysis results
pdm database migrate backup $db_opts

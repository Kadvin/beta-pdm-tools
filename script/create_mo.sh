#!/usr/bin/env sh
DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh create_mo $@

echo Generate factors...
pdm factor ip $total > $factors --start $start

echo Generate templates
pdm template create_mo --sessions $total --bursts 1 < $factors > $pressure

echo Pressuring the server
pdm pressure httperf $pressure -s $server -p $port

echo Get Logs
pdm ftp get ps_userpane.log -u server_log -w log -s $server -p 2121 --to $working
pdm ftp get se_commander.log se_sampling.log -u engine_log -w log -s $engine -p 2121 --to $working


echo "Drop existing tables"
pdm database migrate down $db_opts

echo "Recrate tables"
pdm database migrate up $db_opts

echo Analysis logs
pdm analysis create_mo $working/*.log > $result -t $now $db_opts

echo import analysis results
pdm database import $result $db_opts


echo backup the results
pdm database migrate backup $db_opts

#!/bin/sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh sample_mo $@

echo Retrieve mo keys...
pdm userpane list mcs/NetworkDevice/mos -f mokey > $factors -s $server

echo Generate templates
pdm template sample_mo --sessions 36 --bursts 1 < $factors > $pressure

echo "Pressuring(Sampling) the server"
pdm pressure httperf $pressure -s $server -p 8020
echo Get Logs
pdm ftp get ps_userpane.log -u server_log -w log -s $server -p 2121 --to $working
pdm ftp get se_commander.log se_sampling.log -u engine_log -w log -s $engine -p 2121 --to $working
echo "Drop existing tables"
pdm database migrate down $db_opts
echo "Recreate tables"
pdm database migrate up $db_opts
echo Analysis logs
pdm analysis sample_mo $working/*.log > $result -t $now
echo import analysis results
pdm database import $result $db_opts
pdm database validate user_tasks -c "count(0) = $[ total * 36 ]" $db_opts
pdm database validate user_tasks -c "avg(cost) == 500" $db_opts
pdm database validate user_tasks -c "max(cost) == 1000" $db_opts

echo backup the results
pdm database migrate backup $db_opts


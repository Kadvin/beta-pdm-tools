#!/bin/sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh execute_subscribe $@

pdm ftp get se_sampling.log se_scheduler.log -u engine_log -w log -s $engine -p 2121 --to $working

echo "Drop existing tables"
pdm database migrate down $db_opts
echo "Create tables"
pdm database migrate up $db_opts
echo Analysis logs
pdm analysis execute_subscribe $working/*.log $db_opts > $result
echo import analysis results
pdm database import $result $db_opts
echo backup analysis results
pdm database migrate backup $db_opts

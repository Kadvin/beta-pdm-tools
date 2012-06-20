#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh download_file $@

channel="Windows"
file_name="record_75_1331711400_1331711704.json"

echo "Downloading..."
pdm userpane general_query records/$channel/$file_name/ -s $server

echo Get Logs
pdm ftp get ps_userpane.log -u server_log -w log -s $server -p 2121 --to $working

echo "Drop existing tables"
pdm database migrate down $db_opts

echo "Recrate tables"
pdm database migrate up $db_opts

echo Analysis logs
pdm analysis download_file $working/*.log > $result -t $now $db_opts

echo import analysis results
pdm database import $result $db_opts

echo backup the results
pdm database migrate backup $db_opts

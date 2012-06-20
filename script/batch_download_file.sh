#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh batch_download_file $@

channel='Windows'

echo Get file names...
pdm userpane list records/$channel > $factors -s $server

sed -i 's/http:\/\/[^\/]*//g' $factors

echo Generate templates
pdm template download_file --sessions $total --bursts 1 < $factors > $pressure

echo 'Pressuring(Retrieve) the server'
pdm pressure httperf $pressure -s $server -p 8020

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

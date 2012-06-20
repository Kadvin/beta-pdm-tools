#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh ap_query_mo $@

key_word='101.'

echo "Query MO with key word: $key_word"
pdm adminpane query_mo  $key_word -s $server

echo Get Logs
pdm ftp get ps_adminpane.log -u server_log -w log -s $server -p 2121 --to $working

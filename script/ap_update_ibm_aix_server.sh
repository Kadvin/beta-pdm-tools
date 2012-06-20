#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh ap_update_ibm_aix_server $@

id='630'
domain='test_domain'
ip='9.6.4.2'

echo Add IBMAixServer
pdm adminpane update_ibm_aix_server $id $domain $ip -s $server

echo Get Logs
pdm ftp get ps_adminpane.log -u server_log -w log -s $server -p 2121 --to $working

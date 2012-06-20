#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh ap_add_ibm_aix_server $@

domain='test_domain'
ip='9.6.4.2'

echo Add IBMAixServer
pdm adminpane add_ibm_aix_server $domain $ip -s $server

echo Get Logs
pdm ftp get ps_adminpane.log -u server_log -w log -s $server -p 2121 --to $working

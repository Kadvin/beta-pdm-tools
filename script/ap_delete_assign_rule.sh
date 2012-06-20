#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh ap_delete_assign_rule $@

rule_id='快来看看'

echo Deleting assign-rule
pdm adminpane delete_assign_rule $rule_id -s $server

echo Get Logs
pdm ftp get ps_adminpane.log -u server_log -w log -s $server -p 2121 --to $working

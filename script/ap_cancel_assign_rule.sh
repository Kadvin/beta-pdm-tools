#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh ap_cancel_assign_rule $@

rule_id='windows'

echo Cancel assign-rule
pdm adminpane cancel_assign_rule $rule_id -s $server

echo Get Logs
pdm ftp get ps_adminpane.log -u server_log -w log -s $server -p 2121 --to $working

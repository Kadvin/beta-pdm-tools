#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh ap_update_assign_rule $@

rule_id='windows' #要更新的分配策略的名称
engine_key='631323553090708069' #对其采集引擎进行更新

echo Updating assign-rule
pdm adminpane update_assign_rule $rule_id $engine_key -s $server

echo Get Logs
pdm ftp get ps_adminpane.log -u server_log -w log -s $server -p 2121 --to $working

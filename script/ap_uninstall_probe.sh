#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh ap_uninstall_probe $@

probe_id='cn.com.betasoft.dsat.model-linux_server-1.0.0'

echo Uninstall Probe Package
pdm adminpane uninstall_probe $probe_id -s $server

echo Get Logs
pdm ftp get ps_adminpane.log -u server_log -w log -s $server -p 2121 --to $working

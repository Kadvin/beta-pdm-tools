#!/usr/bin/env sh

DIR=`dirname $BASH_SOURCE`
. $DIR/share.sh ap_new_session $@

echo Login...
start_at=`date +%T.%N`
pdm adminpane new_session -s $server
end_at=`date +%T.%N`

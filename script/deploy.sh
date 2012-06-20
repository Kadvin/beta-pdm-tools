#! /bin/bash

SRC_FTP=20.0.8.222
SRC_PORT=21
DST_WIN=20.0.9.111
# Find the latest file available to be test
version=`pdm ftp list  -s $SRC_FTP -p $SRC_PORT -u anonymous -w k@a.com | tail -n 1 |  awk '{print $NF}'`
echo "Perform test against version $version"





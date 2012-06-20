#!/usr/bin/env sh

# share.sh case_name target_server total

if ! [ -z $2 ]; then
  server=$2
fi

if [ -z $server ]; then
  server="20.0.8.127"
  echo "Target server(default) is: $server"
else
  echo "Target server is: $server"
fi

if [ -z $engine ]; then
  engine="20.0.8.127"
  echo "Target engine(default) is: $engine"
fi

if [ -z $port ]; then
  port=8020
fi

if ! [ -z $3 ]; then
  total=$3
else
  total=50
fi
if ! [ $strt ]; then
  start="10.10.10.10"
fi

today=`date +%y_%m_%d`
working=$1_$today
factors=$working/factors.data
pressure=$working/pressure.data
result=$working/result.data
now=`date +%T`,000

if [ -z $db_opts ]; then
  db_opts="--database pdm7-opts -u root -w root"
  echo "Target database(default) is: $db_opts"
else
  echo "Target database is: $db_opts"
fi

if [ -d $working ]
then
  echo "folder $working exist, remove it now"
  rm -rf ./$working
fi
echo "create task folder: $working"
mkdir $working

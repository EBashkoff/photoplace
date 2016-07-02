#!/usr/bin/env bash
PID=$(pgrep -f ^puma | xargs)

if [ -n "$PID" ]; then
  echo "Puma Processes: $PID"
  for WORD in $PID
  do
  	echo "Killing Puma process $WORD"
    kill -9 $WORD
  done
else
  echo "No Puma Processes Found"
fi

PID=$(pgrep -f memcached | xargs)

if [ -n "$PID" ]; then
  echo "Memcached Processes: $PID"
  for WORD in $PID
  do
  	echo "Killing Memcached process $WORD"
    kill -9 $WORD
  done
else
  echo "No Memcached Processes Found"
fi

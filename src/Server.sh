#!/usr/bin/env bash
set -euo pipefail

start_server() {
  printf "Starting server...\n"
  read -r -p "What port do you want to use?: " port

  ip=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
  printf "Listening on $ip:$port\n"

  cat $PIPE_IN | nc -l $port >$PIPE_OUT &

  (
    while read line; do
      echo "Received: $line"
    done <$PIPE_OUT
  ) &
}

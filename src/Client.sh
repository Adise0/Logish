#!/usr/bin/env bash
set -euo pipefail

start_client() {
  printf "Starting client...\n"
  read -r -p "Ip to connect to: " ip
  read -r -p "Port: " port

  printf "Connecting to $ip:$port\n"

  cat $PIPE_IN | nc $ip $port >$PIPE_OUT &

  (
    while read line; do
      echo "Received: $line"
    done <$PIPE_OUT
  ) &

  echo "Hello server, I'm client!" >$PIPE_IN
}

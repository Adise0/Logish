#!/usr/bin/env bash
set -euo pipefail

start_client() {
  printf "Starting client...\n"
  read -r -p "Ip to connect to: " ip
  read -r -p "Port: " port

  printf "Connecting to $ip:$port\n"

  nc
}

# # sender → socket
# cat in | nc localhost 1234 > out &

# # receive parser
# while read line; do
#     echo "RECV: $line"
# done < out

# # send manually
# echo "hello" > in

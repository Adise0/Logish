#!/usr/bin/env bash
set -euo pipefail

start_client() {
  printf "Starting client...\n"

  default_ip=localhost
  default_port=5555

  read -r -p "Ip to connect to (Default: $default_ip): " ip
  read -r -p "Port (Default: $default_port): " port
  [[ -z "${ip}" ]] && ip=$default_ip
  [[ -z "${port}" ]] && port=$default_port

  if ! nc -z -w 1 "$ip" "$port" 2>/dev/null; then
    echo "❌ Cannot connect to $ip:$port"
    return 1
  fi

  coproc NC { nc "$ip" "$port" 2>/dev/null; }
  nc_pid=$NC_PID

  exec 3<&"${NC[0]}"
  exec 4>&"${NC[1]}"

  {
    while IFS= read -r line <&3; do
      printf "Received: %s\n" "$line"
    done
  } &
  reader_pid=$!

  printf "✅ Connected\n"
  printf "%s\n" "Hello server, I'm client!" >&4

  wait "$nc_pid"
}

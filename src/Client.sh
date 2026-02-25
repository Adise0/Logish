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

  coproc NC { exec nc "$ip" "$port" 2>/dev/null; }
  nc_pid=$NC_PID

  exec 3<&"${NC[0]}"
  exec 4>&"${NC[1]}"

  {
    while true; do
      # Don’t block forever; wake up every 200ms
      if IFS= read -r -t 0.2 line <&3; then
        printf "Received: %s\n" "$line"
        continue
      fi

      # If nc died, we're done
      if ! kill -0 "$nc_pid" 2>/dev/null; then
        printf "❌ Disconnected (nc exited)\n" >&2
        break
      fi

      # If nc is alive but no ESTABLISHED socket -> connection is gone; nc is just stuck
      if ! ss -Htnp 2>/dev/null | grep -F "pid=$nc_pid" | grep -q ESTAB; then
        printf "❌ Disconnected (socket gone; killing stuck nc)\n" >&2
        kill "$nc_pid" 2>/dev/null || true
        break
      fi
    done

    # cleanup fds
    exec 3<&- 4>&-
  } &
  reader_pid=$!

  printf "✅ Connected\n"
  printf "%s\n" "$(send_message "HELLO2" "")" >&4

  # Wait for *either* the reader or nc to exit
  wait -n "$reader_pid" "$nc_pid" 2>/dev/null || true

  # Cleanup
  kill "$reader_pid" "$nc_pid" 2>/dev/null || true
  exec 3<&- 4>&-
}

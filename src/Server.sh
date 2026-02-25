#!/usr/bin/env bash
set -euo pipefail

start_server() {

  printf "Starting server...\n"
  local default_port=5555
  local port
  read -r -p "What port do you want to use? (Default $default_port): " port
  [[ -z "${port}" ]] && port=$default_port

  local ip
  ip=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
  printf "Listening on %s:%s\n" "$ip" "$port"
  printf "(Waiting for clients...)\n"

  while ((!SHUTTING_DOWN)); do
    # Start a single listening session (one client connection per loop)
    coproc NC { nc -l "$port" 2>/dev/null; }
    nc_pid=$NC_PID

    # Duplicate coproc fds to stable ones (so background reads don't get Bad FD)
    exec 3<&"${NC[0]}"
    exec 4>&"${NC[1]}"

    local connected=0

    while IFS= read -r line <&3; do
      if ((connected == 0)); then
        printf "Client connected\n"
        connected=1
      fi
      printf "Received: %s\n" "$line"
      ((SHUTTING_DOWN)) && break
    done

    if ((SHUTTING_DOWN)); then
      kill "$nc_pid" 2>/dev/null || true
      wait "$nc_pid" 2>/dev/null || true
      break
    fi

    wait "$nc_pid" 2>/dev/null || true

    if ((connected == 1)); then
      printf "Client disconnected\n\n"
    fi
  done
}

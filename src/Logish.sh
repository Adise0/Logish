#!/usr/bin/env bash
set -euo pipefail

source "src/utils/Prompt.sh"
source "src/utils/CreatePipes.sh"
source "src/Client.sh"
source "src/Server.sh"

type=$(prompt "Choose an option:" "Client" "Server")

if [[ $type = 0 ]]; then
  start_client
else
  start_server
fi

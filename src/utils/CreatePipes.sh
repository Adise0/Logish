#!/usr/bin/env bash
set -euo pipefail

PIPE_IN="tmp/in"
PIPE_OUT="tmp/out"

cleanup() {
  rm -r tmp
}

trap cleanup EXIT

mkdir tmp
mkfifo "$PIPE_IN" "$PIPE_OUT"

#!/usr/bin/env bash
set -euo pipefail

PIPE_DIR=$(mktemp -d)
PIPE_IN="$PIPE_DIR/in"
PIPE_OUT="$PIPE_DIR/out"

cleanup() {
  rm -rf $PIPE_DIR
}

trap cleanup EXIT

mkfifo "$PIPE_IN" "$PIPE_OUT"

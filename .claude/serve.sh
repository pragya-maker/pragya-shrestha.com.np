#!/bin/bash
# Minimal static file server using bash + /dev/tcp workaround
# Falls back to socat or netcat if available
PORT="${1:-5500}"
DIR="$(cd "$(dirname "$0")/.." && pwd)"

serve_response() {
  local FILE="$DIR/index.html"
  local CONTENT
  CONTENT=$(cat "$FILE")
  local LEN=${#CONTENT}
  echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: $LEN\r\nConnection: close\r\n\r\n$CONTENT"
}

if command -v socat &>/dev/null; then
  echo "Serving on http://localhost:$PORT"
  socat TCP-LISTEN:$PORT,reuseaddr,fork SYSTEM:"$(realpath "$0") --respond"
elif command -v ncat &>/dev/null; then
  echo "Serving on http://localhost:$PORT"
  while true; do
    serve_response | ncat -l -p $PORT -q 1
  done
else
  echo "Error: No suitable network tool found (socat/ncat). Please install Node.js: https://nodejs.org" >&2
  exit 1
fi

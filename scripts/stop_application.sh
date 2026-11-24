#!/usr/bin/env bash
set -euo pipefail

APP_DIR=/opt/flask-app
PID_FILE=/var/run/flask-app.pid

if [[ ! -f "$PID_FILE" ]]; then
  exit 0
fi

pid=$(cat "$PID_FILE")
if [[ ! "$pid" =~ ^[0-9]+$ ]] || ! kill -0 "$pid" 2>/dev/null; then
  rm -f "$PID_FILE"
  exit 0
fi

if [[ ! -r "/proc/$pid/cmdline" ]]; then
  rm -f "$PID_FILE"
  exit 0
fi

command_line=$(tr '\0' ' ' < "/proc/$pid/cmdline")
if [[ "$command_line" != *"$APP_DIR/application.py"* ]]; then
  rm -f "$PID_FILE"
  exit 0
fi

kill "$pid"
for ((attempt = 0; attempt < 30; attempt++)); do
  if ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$PID_FILE"
    exit 0
  fi
  sleep 1
done

echo "Flask application process $pid did not stop within 30 seconds" >&2
exit 1

#!/usr/bin/env bash
set -euo pipefail

APP_DIR=/opt/flask-app
PID_FILE=/var/run/flask-app.pid
PYTHON="$APP_DIR/venv/bin/python"

if [[ ! -x "$PYTHON" ]]; then
  echo "Application virtual environment is missing; install dependencies first" >&2
  exit 1
fi

if [[ -f "$PID_FILE" ]]; then
  pid=$(cat "$PID_FILE")
  if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
    if [[ -r "/proc/$pid/cmdline" ]]; then
      command_line=$(tr '\0' ' ' < "/proc/$pid/cmdline")
      if [[ "$command_line" == *"$APP_DIR/application.py"* ]]; then
        echo "Flask application is already running with PID $pid"
        exit 0
      fi
    fi
  fi
  rm -f "$PID_FILE"
fi

cd "$APP_DIR"
nohup "$PYTHON" "$APP_DIR/application.py" >> /var/log/flask-app.log 2>&1 &
pid=$!
printf '%s\n' "$pid" > "$PID_FILE"

for ((attempt = 0; attempt < 30; attempt++)); do
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "Flask application exited during startup; see /var/log/flask-app.log" >&2
    rm -f "$PID_FILE"
    exit 1
  fi
  if "$PYTHON" -c 'import urllib.request; urllib.request.urlopen("http://127.0.0.1:8000/health", timeout=1)' >/dev/null 2>&1; then
    exit 0
  fi
  sleep 1
done

echo "Flask application did not become healthy on port 8000; see /var/log/flask-app.log" >&2
exit 1

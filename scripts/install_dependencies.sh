#!/usr/bin/env bash
set -euo pipefail

APP_DIR=/opt/flask-app

command -v python3 >/dev/null 2>&1 || {
  echo "python3 is required to install the application dependencies" >&2
  exit 1
}

python3 -m venv "$APP_DIR/venv"
"$APP_DIR/venv/bin/python" -m pip install --upgrade pip
"$APP_DIR/venv/bin/python" -m pip install -r "$APP_DIR/requirements.txt"

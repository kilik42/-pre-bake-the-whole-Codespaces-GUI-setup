#!/usr/bin/env bash
set -e

# Ensure DISPLAY is set (Codespaces terminals should pick this up from .bashrc)
export DISPLAY="${DISPLAY:-:1}"

if [ -z "$1" ]; then
  echo "Usage: ./run_gui.sh your_script.py"
  exit 1
fi

python3 "$1"


#Make it executable:
chmod +x run_gui.sh

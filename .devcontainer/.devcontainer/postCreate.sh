#!/usr/bin/env bash
set -e

echo "Installing GUI dependencies (Xvfb, x11vnc, fluxbox, noVNC)..."
sudo apt-get update -y
sudo apt-get install -y \
  xvfb x11vnc fluxbox websockify novnc \
  xterm dbus-x11

echo "Done installing GUI dependencies."

#Make it executable:
chmod +x .devcontainer/postCreate.sh

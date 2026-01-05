#!/usr/bin/env bash
set -e

DISPLAY_NUM=":1"
SCREEN_RES="1280x720x24"
VNC_PORT="5900"
NOVNC_PORT="6080"

# Helper: check if a process is already running
is_running () {
  pgrep -f "$1" >/dev/null 2>&1
}

echo "Starting GUI environment for Codespaces..."

# 1) Start Xvfb (virtual display)
if ! is_running "Xvfb $DISPLAY_NUM"; then
  echo "Starting Xvfb on $DISPLAY_NUM..."
  nohup Xvfb "$DISPLAY_NUM" -screen 0 "$SCREEN_RES" >/tmp/xvfb.log 2>&1 &
else
  echo "Xvfb already running."
fi

# Export DISPLAY for this session and future terminals
if ! grep -q "export DISPLAY=$DISPLAY_NUM" ~/.bashrc; then
  echo "export DISPLAY=$DISPLAY_NUM" >> ~/.bashrc
fi
export DISPLAY="$DISPLAY_NUM"

# 2) Start a lightweight window manager (fluxbox)
if ! is_running "fluxbox"; then
  echo "Starting fluxbox..."
  nohup fluxbox >/tmp/fluxbox.log 2>&1 &
else
  echo "fluxbox already running."
fi

# 3) Start x11vnc (VNC server) bound to localhost only (keeps it private)
if ! is_running "x11vnc.*$VNC_PORT"; then
  echo "Starting x11vnc on localhost:$VNC_PORT..."
  nohup x11vnc -display "$DISPLAY_NUM" -nopw -forever -shared -rfbport "$VNC_PORT" -localhost >/tmp/x11vnc.log 2>&1 &
else
  echo "x11vnc already running."
fi

# 4) Start noVNC/websockify on 6080
# Prefer the system noVNC web directory
NOVNC_WEB="/usr/share/novnc"
if [ ! -d "$NOVNC_WEB" ]; then
  echo "ERROR: noVNC web directory not found at $NOVNC_WEB"
  exit 1
fi

if ! is_running "websockify.*$NOVNC_PORT"; then
  echo "Starting websockify/noVNC on :$NOVNC_PORT -> localhost:$VNC_PORT ..."
  nohup websockify --web="$NOVNC_WEB" "$NOVNC_PORT" "localhost:$VNC_PORT" >/tmp/novnc.log 2>&1 &
else
  echo "websockify/noVNC already running."
fi

echo ""
echo "✅ GUI environment ready."
echo "➡️ Open the forwarded port $NOVNC_PORT in Codespaces to see the desktop."
echo "➡️ In any terminal:  export DISPLAY=$DISPLAY_NUM  (usually already set)"

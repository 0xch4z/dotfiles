#!/usr/bin/env bash

set -e

state="${XDG_RUNTIME_DIR:-/tmp}/hypridle-suspend.inhibit"

if [ -e "$state" ]; then
  value="$(cat "$state" 2>/dev/null || true)"
  if [ "$value" = "never" ] || [ -z "$value" ]; then
    exit 0
  fi
  now="$(date +%s)"
  if [ "$now" -lt "$value" ]; then
    exit 0
  fi
  rm -f "$state"
fi

systemctl suspend

#!/usr/bin/env bash

set -eou pipefail

state="${XDG_RUNTIME_DIR:-/tmp}/hypridle-suspend.inhibit"
cmd="${1:-status}"

IDLE_SECONDS="{{ IDLE_SECONDS }}"

case "$cmd" in
  off | inhibit | disable | never)
    printf 'never\n' >"$state"
    echo "auto-suspend: DISABLED — will not suspend on idle."
    echo "run 'idle-ctl on' to restore the default (${IDLE_SECONDS} idle)."
    ;;
  on | release | enable | reset | default)
    rm -f "$state"
    echo "auto-suspend: enabled — suspends after ${IDLE_SECONDS}s."
    ;;
  status | get)
    if [ -e "$state" ]; then
      echo "auto-suspend: DISABLED (will not suspend on idle)"
    else
      echo "auto-suspend: enabled (after ${IDLE_SECONDS}s)"
    fi
    ;;
  -h | --help | help)
    cat <<'EOF'
idle-ctl — control hypridle auto-suspend

Usage:
  idle-ctl off       disable auto-suspend (stay awake indefinitely)
  idle-ctl on        re-enable auto-suspend (the default)
  idle-ctl status    show current state (default)
EOF
    ;;
  *)
    echo "idle-ctl: unknown command '$cmd' (try: off, on, status)" >&2
    exit 1
    ;;
esac

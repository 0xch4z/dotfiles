set -eu

action="${1:-reconcile}"
internal={{ INTERNAL_MONITOR }}
internal_rule={{ INTERNAL_MONITOR_RULE }}
preferred_external={{ PREFERRED_EXTERNAL_MONITOR }}

read_lid_state() {
  for state_file in /proc/acpi/button/lid/*/state; do
    [ -e "$state_file" ] || continue
    if grep -qi closed "$state_file"; then
      echo closed
      return
    fi
  done
  echo open
}

if [ "$action" = reconcile ]; then
  action="$(read_lid_state)"
fi

external="$(
  hyprctl monitors -j | jq -r --arg internal "$internal" --arg preferred "$preferred_external" '
    [ .[] | select(.name != $internal and (.disabled | not)) | .name ] as $external |
    if $preferred != "" and (($external | index($preferred)) != null) then $preferred else ($external[0] // "") end
  '
)"

case "$action" in
  closed)
    if [ -n "$external" ]; then
      hyprctl workspaces -j | jq -r --arg internal "$internal" '.[] | select(.monitor == $internal) | .id' |
        while IFS= read -r workspace; do
          [ -n "$workspace" ] || continue
          hyprctl dispatch moveworkspacetomonitor "$workspace" "$external" >/dev/null || true
        done

      hyprctl dispatch focusmonitor "$external" >/dev/null || true
      hyprctl keyword monitor "$internal,disable" >/dev/null
    fi
    ;;
  open)
    hyprctl keyword monitor "$internal_rule" >/dev/null
    ;;
  *)
    echo "usage: hyprland-lid-switch closed|open|reconcile" >&2
    exit 64
    ;;
esac

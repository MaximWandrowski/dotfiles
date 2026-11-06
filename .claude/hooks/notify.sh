#!/usr/bin/env bash
# Claude Code hook (Notification + Stop): ring the tmux bell and send a desktop
# notification via mako -- unless you're already looking at this Claude pane.
input=$(cat)
msg=$(jq -r '.message // "Finished responding"' <<<"$input")
proj=$(basename "$(jq -r '.cwd' <<<"$input")")
loc=""
if [ -n "$TMUX_PANE" ]; then
  # ring the bell in Claude's own pane -> window_bell_flag -> yellow tab
  printf '\a' > "$(tmux display -p -t "$TMUX_PANE" '#{pane_tty}')"
  loc=" ($(tmux display -p -t "$TMUX_PANE" '#S:#I'))"
  # skip the popup if a focused client (Alacritty has focus; needs tmux focus-events on)
  # is currently showing this exact pane
  if tmux list-clients -F '#{client_flags} #{pane_id}' \
       | grep -qE "(^|,)focused(,| ).* ${TMUX_PANE}\$"; then
    exit 0
  fi
fi
notify-send -a "Claude Code" "Claude · $proj$loc" "$msg"
exit 0

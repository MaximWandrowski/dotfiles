#!/usr/bin/env bash
# Claude Code hook (Notification + Stop): ring the tmux bell and send a desktop
# notification via mako -- unless you're already looking at this Claude pane.
# Clicking the notification jumps to the Claude pane and focuses Alacritty (sway).
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

# jump to the Claude pane: switch the most recently used tmux client to it,
# then focus the sway window that hosts that client
focus_pane() {
  local client pid
  read -r _ client pid < <(tmux list-clients -F '#{client_activity} #{client_name} #{client_pid}' | sort -rn | head -1)
  [ -n "$client" ] || return
  tmux switch-client -c "$client" -t "$(tmux display -p -t "$TMUX_PANE" '#{session_id}')" \; \
       select-window -t "$TMUX_PANE" \; select-pane -t "$TMUX_PANE"
  # walk up from the tmux client to the terminal process that owns a sway window
  while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
    swaymsg -q "[pid=$pid] focus" 2>/dev/null && return
    pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
  done
}

# wait for the click in the background so the hook returns immediately
(
  action=$(notify-send -a "Claude Code" --action=default=Open "Claude · $proj$loc" "$msg")
  [ "$action" = default ] && [ -n "$TMUX_PANE" ] && focus_pane
) </dev/null >/dev/null 2>&1 &
disown
exit 0

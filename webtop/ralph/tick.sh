#!/bin/bash
# One pass over projects.conf (lines of <repo path> <channel id> <agent>): at most one ticket per project. Run every 20 seconds by the webtop's svc-ralph s6 service.
dir=$(dirname "$(realpath "$0")")
conf=$HOME/.config/ralph/projects.conf
logs=$HOME/.local/state/ralph
mkdir -p "$logs"
[ -f "$conf" ] || exit 0  # written by the webtop's init.sh from its projects list

grep -vE '^\s*(#|$)' "$conf" | while read -r repo channel agent; do
  log=$logs/$(basename "$repo").log
  [ "$agent" = claude ] || { echo "$(date -Is) skip: agent '$agent' not supported" >> "$log"; continue; }
  export RALPH_CHANNEL=$channel
  "$dir/discord.sh" ready > /dev/null 2>> "$log" || continue  # keeps idle ticks out of the log
  ( echo "=== $(date -Is)"; cd "$repo" && "$dir/afk.sh" 1 ) < /dev/null >> "$log" 2>&1
done

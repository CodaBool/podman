#!/bin/bash
# One pass over projects.conf: at most one ticket per project. Run every minute by the webtop's svc-ralph s6 service.
dir=$(dirname "$(realpath "$0")")
conf=$HOME/.config/ralph/projects.conf
logs=$HOME/.local/state/ralph
mkdir -p "$(dirname "$conf")" "$logs"
[ -f "$conf" ] || cat > "$conf" <<'CONF'
# One project per line: <repo path> <discord forum channel id> <agent>
# agent is claude for now. Example:
# /config/code/mygame 123456789012345678 claude
CONF

grep -vE '^\s*(#|$)' "$conf" | while read -r repo channel agent; do
  log=$logs/$(basename "$repo").log
  [ "$agent" = claude ] || { echo "$(date -Is) skip: agent '$agent' not supported" >> "$log"; continue; }
  export RALPH_CHANNEL=$channel
  "$dir/discord.sh" ready 2>> "$log" || continue  # keeps idle ticks out of the log
  ( echo "=== $(date -Is)"; cd "$repo" && "$dir/afk.sh" 1 ) < /dev/null >> "$log" 2>&1
done

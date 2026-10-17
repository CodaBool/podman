#!/bin/bash
# AFK: up to N headless iterations, one ticket each. Usage: afk.sh <iterations>
set -eo pipefail
[ -z "$1" ] && { echo "Usage: $0 <iterations>"; exit 1; }
dir=$(dirname "$(realpath "$0")")
exec 9>"$(git rev-parse --git-dir)/ralph.lock"; flock -n 9 || { echo "ralph already running"; exit 0; }

stream_text='select(.type == "assistant").message.content[]? | select(.type == "text").text // empty | . + "\n\n"'
tmpfile=$(mktemp); trap 'rm -f "$tmpfile"' EXIT

for ((i=1; i<=$1; i++)); do
  "$dir/discord.sh" ready > /dev/null || { echo "No Ready tickets."; break; }
  "$dir/sync.sh" || break
  export RALPH_EFFORT; RALPH_EFFORT=$("$dir/discord.sh" effort)
  claude --effort "$RALPH_EFFORT" --mcp-config "$dir/mcp.json" --dangerously-skip-permissions --verbose --print --output-format stream-json "$("$dir/context.sh")" \
    | grep --line-buffered '^{' | tee "$tmpfile" | jq --unbuffered -rj "$stream_text"
  jq -r 'select(.type == "result").result // empty' "$tmpfile" | grep -q '<promise>NO MORE TASKS</promise>' && break
done

#!/bin/bash
# Prints the calling Claude session's context size as a percent of the 150k smart zone, e.g. `28%`.
# Reads the last turn's usage from the session transcript; only works from a Bash tool call, which sets CLAUDE_CODE_SESSION_ID.
: "${CLAUDE_CODE_SESSION_ID:?run me from inside a Claude session}"
log=$(ls "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/projects/*/"$CLAUDE_CODE_SESSION_ID".jsonl 2>/dev/null | head -1)
[ -n "$log" ] || { echo "no transcript for session $CLAUDE_CODE_SESSION_ID"; exit 1; }
jq -rs '[.[] | select(.type == "assistant").message.usage | select(.)] | last
  | .input_tokens + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0) + .output_tokens
  | "\(. / 1500 | round)%"' "$log"

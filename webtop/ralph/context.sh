#!/bin/bash
# Prints the ralph prompt: recent commits + open tickets + loop instructions. Run from the project root.
dir=$(dirname "$(realpath "$0")")
echo "# RECENT COMMITS"; git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found"
echo "# OPEN TICKETS"
"$dir/discord.sh" tickets
echo "# TICKET TOOL"
echo "Set a ticket's tag, optionally replying in its post: \`$dir/discord.sh tag <post id> <tag> [reply]\`. It prints nothing on success and an error on failure, so don't re-read the post to confirm."
echo "Post a file in a ticket: \`$dir/discord.sh attach <post id> <file> [message]\`. Same output rules."
cat "$dir/prompt.md"
# Tool-specific sections, only for projects that use the tool
[ -z "$(find . -path '*/.*' -prune -o -name project.godot -print -quit)" ] || sed "s|\$RALPH|$dir|g" "$dir/godot.md"

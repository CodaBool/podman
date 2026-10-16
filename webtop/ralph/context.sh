#!/bin/bash
# Prints the ralph prompt: recent commits + open tickets + loop instructions. Run from the project root.
dir=$(dirname "$(realpath "$0")")
echo "# RECENT COMMITS"; git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found"
echo "# OPEN TICKETS"
"$dir/discord.sh" tickets
echo "# TICKET TOOL"
echo "Set a ticket's tag, optionally replying in its post: \`$dir/discord.sh tag <post id> <tag> [reply]\`"
cat "$dir/prompt.md"

#!/bin/bash
# Prints the ralph prompt: recent commits + open tickets + loop instructions. Run from the project root.
dir=$(dirname "$(realpath "$0")")
echo "# RECENT COMMITS"; git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found"
echo "# OPEN TICKETS"
"$dir/discord.sh" tickets --ready-full
echo "# TICKET TOOL"
echo "Set a ticket's tag, optionally replying in its post: \`$dir/discord.sh tag <post id> <tag> [reply]\`. It prints nothing on success and an error on failure, so don't re-read the post to confirm."
echo "Post a file in a ticket: \`$dir/discord.sh attach <post id> <file> [message]\`. Same output rules."
echo "Open a new ticket: \`$dir/discord.sh create <tag> <title> <body>\`. It prints the new post id."
echo "Screenshot the whole desktop (any app: Brave, Blender, the Godot editor) with \`$dir/display.sh grim <file>.png\`, or a region with \`grim -g \"x,y wxh\"\`, then attach it."
sed "s|\$RALPH|$dir|g" "$dir/prompt.md"
# Set by afk.sh and once.sh from setup.sh when the project's tools/setup.sh failed
[ -z "$RALPH_SETUP_WARNING" ] || { echo "# PROJECT SETUP"; echo "$RALPH_SETUP_WARNING"; }
# Set by afk.sh and once.sh from `discord.sh effort`; medium sessions take any ticket
if [ -n "$RALPH_EFFORT" ] && [ "$RALPH_EFFORT" != medium ]; then
  echo "# EFFORT"
  echo "This session runs at \`$RALPH_EFFORT\` effort, meant for the \`Ready\` tickets whose human's last message asks for it (\`[$RALPH_EFFORT]\`, alone or combined like \`[%,$RALPH_EFFORT]\`). Pick only among those. If none of them qualifies, stop without the NO MORE TASKS promise: a later iteration takes the other tickets."
fi
sed "s|\$RALPH|$dir|g" "$dir/browser.md"
# Tool-specific sections, only for projects that use the tool
[ -z "$(find . -path '*/.*' -prune -o -name project.godot -print -quit)" ] || sed "s|\$RALPH|$dir|g" "$dir/godot.md"

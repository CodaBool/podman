#!/bin/bash
# Human-in-the-loop: one interactive iteration you can watch and steer.
dir=$(dirname "$(realpath "$0")")
export RALPH_SETUP_WARNING; RALPH_SETUP_WARNING=$("$dir/setup.sh")
export RALPH_EFFORT; RALPH_EFFORT=$("$dir/discord.sh" effort)
claude --effort "$RALPH_EFFORT" --mcp-config "$dir/mcp.json" --permission-mode acceptEdits "$("$dir/context.sh")"

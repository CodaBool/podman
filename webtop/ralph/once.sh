#!/bin/bash
# Human-in-the-loop: one interactive iteration you can watch and steer.
dir=$(dirname "$(realpath "$0")")
claude --mcp-config "$dir/mcp.json" --permission-mode acceptEdits "$("$dir/context.sh")"

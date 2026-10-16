
# GODOT

This section is here only because this repo is a Godot project. It doesn't apply to work outside Godot.

The `godot` MCP server runs projects and reads their debug output (`run_project`, `get_debug_output`, `stop_project`) and edits scenes. It can't take screenshots. If it isn't connected, use the `godot` CLI the same way; don't spend the session retrying it.

Screenshots are cheap, so take many. Every time you run a scene to debug, check a fix or look at a visual change, screenshot it and attach it to the ticket:

    png=$($RALPH/godot-shot.sh res://path/to/scene.tscn)   # prints the PNG path; optional 2nd arg: frames to run first (default 60)
    $RALPH/discord.sh attach <post id> "$png" "what the shot shows"

Post one per scene you ran, and before and after for visual changes. Use `godot-shot.sh` rather than hand-rolled xvfb, scrot or `--headless` commands: `--headless` renders nothing, and the script handles the display, asset import and frame capture. If a shot comes out black or wrong, say so in the reply and attach it anyway. For animations or effects that take time to settle, raise the frame count.

# ralph

Project-agnostic loop that turns Discord forum posts into commits. Run `once.sh`, `afk.sh` and `context.sh` from the project root.

| Script | What |
| --- | --- |
| `once.sh` | One interactive iteration (HITL). Watch it, steer it. |
| `afk.sh N` | Up to N headless iterations, one ticket each. Exits early when no post is tagged `Ready`. Lock-protected. |
| `tick.sh` | Runs `afk.sh 1` in every project in `~/.config/ralph/projects.conf`. The webtop's `svc-ralph` s6 service calls it every minute. Idle ticks aren't logged. |
| `discord.sh` | The ticket tracker: `ready`, `tickets`, `tag <post> <tag> [reply]`, `attach <post> <file> [message]` against the forum in `RALPH_CHANNEL`. |
| `context.sh` | Prints the prompt: last 5 commits, open tickets, `prompt.md`, plus `godot.md` when the repo has a `project.godot`. |
| `godot-shot.sh` | Renders a Godot scene with Movie Maker (Xvfb when there's no display) and prints a PNG path for `discord.sh attach`. |
| `mcp.json` | MCP servers `once.sh` and `afk.sh` load: `godot` (godot-mcp, installed in the image). |

Env: `RALPH_CHANNEL` (the project's Discord forum channel id, set by `tick.sh`; export it yourself for `once.sh`), `DISCORD_TOKEN` (bot token). Needs `claude`, `jq`, `curl`, `flock`; `godot-shot.sh` also needs `godot`, `xvfb-run` and `timeout`. The bot needs View Channel, Send Messages in Threads, Read Message History, Manage Threads (to set tags) and Attach Files (for `attach`) on the forum.

## Ticket lifecycle

One forum post per ticket. Its tag is its state:

- `Ready`: an agent can finish it without asking anything.
- `Blocked`: waits on another ticket. Ralph re-tags it `Ready` when it resolves the blocker; you can too.
- `Claimed`: ralph is working on it. If ralph died mid-ticket (log ends without a reply), re-tag it `Ready`.
- `Resolved`: done, committed if it needed code. Ralph replies with what it did. Questions and chat land here too.
- `Needs Info`: ralph needs a decision or hands only you have. Its reply is the question. Answer in the post and re-tag `Ready`.

## Where Matt Pocock's flow fits

1–3 are HITL, 4–5 are what ralph does per ticket.

1. `/grill-with-docs`: align. Interactive.
2. `/to-spec`: write the spec. Skip if small.
3. Tickets: one forum post per vertical slice, tagged `Ready`. This is the hand-off: anything AFK must be a ticket.
4. Implement + 5. `/code-review`: one ralph iteration each ticket, fresh context every time, so the smart zone (<150k tokens) holds by construction.

Small things skip 1–3: write the post and tag it `Ready`.

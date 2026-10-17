# ralph

Project-agnostic loop that turns Discord forum posts into commits. Run `once.sh`, `afk.sh` and `context.sh` from the project root.

| Script | What |
| --- | --- |
| `once.sh` | One interactive iteration (HITL). Watch it, steer it. |
| `afk.sh N` | Up to N headless iterations, one ticket each. Exits early when no post is tagged `Ready`. Lock-protected. Runs `sync.sh` before each one. |
| `sync.sh` | Rebases the branch onto its upstream so the agent starts from what you pushed. A failed fetch just waits for the next tick; a dirty tree or a conflict is aborted and every `Ready` ticket is tagged `Needs Info` with git's error. Fix it in the webtop, re-tag `Ready`. |
| `tick.sh` | Runs `afk.sh 1` in every project in `~/.config/ralph/projects.conf`, which the webtop's `init.sh` writes (and clones) from its `projects` list on every start. The webtop's `svc-ralph` s6 service calls it every 20 seconds. Idle ticks aren't logged. |
| `discord.sh` | The ticket tracker: `ready` (prints `Ready` post ids), `tickets`, `tag <post> <tag> [reply]`, `attach <post> <file> [message]` against the forum in `RALPH_CHANNEL`. |
| `context.sh` | Prints the prompt: last 5 commits, open tickets, `prompt.md`, `browser.md`, plus `godot.md` when the repo has a `project.godot`. |
| `tokens.sh` | Prints the calling session's context use, like `42k/150k (28%)`, from its transcript. Ralph ends a `Resolved` reply with it when your last message in the post contains `[%]`. |
| `godot-shot.sh` | Renders a Godot scene with Movie Maker and prints a PNG path for `discord.sh attach`. |
| `display.sh` | Runs a command on the webtop's sway desktop (finds its Wayland and Xwayland sockets, since s6 services don't inherit them), or a private Xvfb when it isn't up. `godot-shot.sh`, the `godot` MCP server and `browser.sh` go through it. |
| `browser.sh` | Starts the agents' Chromium unless it's already up: own profile (`~/.config/ralph/chromium`, not your Brave one), DevTools on `127.0.0.1:9222`, on the sway desktop so you can watch and share its window, or headless with `BROWSER_HEADLESS=1`. Either way it renders on the GPU. It outlives the session, so tabs and logins carry over. `browser.sh mcp` then runs chrome-devtools-mcp attached to it. Log in `~/.local/state/ralph/browser.log`. |
| `mcp.json` | MCP servers `once.sh` and `afk.sh` load: `godot` (godot-mcp, installed in the image). The `browser` server isn't here: the webtop's `init.sh` registers it for every Claude session, ralph's included. |

Env: `BROWSER_HEADLESS` (set it to start the browser headless; ignored while one is already running), `RALPH_CHANNEL` (the project's Discord forum channel id, set by `tick.sh`; export it yourself for `once.sh`), `DISCORD_TOKEN` (bot token). Needs `claude`, `jq`, `curl`, `flock`; `godot-shot.sh` also needs `godot` and `timeout`, plus `xvfb-run` for the no-desktop fallback. The bot needs View Channel, Send Messages in Threads, Read Message History, Manage Threads (to set tags) and Attach Files (for `attach`) on the forum.

## Ticket lifecycle

One forum post per ticket. Its tag is its state:

- `Ready`: an agent can finish it without asking anything.
- `Blocked`: waits on another ticket. Ralph re-tags it `Ready` when it resolves the blocker; you can too.
- `Claimed`: ralph is working on it. If ralph died mid-ticket (log ends without a reply), re-tag it `Ready`.
- `Resolved`: done, committed and pushed to `main` if it needed code (ralph rebases onto whatever was pushed meanwhile and resolves conflicts itself; if it can't, it ends in `Needs Info`). Ralph replies with what it did. Questions and chat land here too.
- `Needs Info`: ralph needs a decision or hands only you have. Its reply is the question. Answer in the post and re-tag `Ready`.

## Where Matt Pocock's flow fits

1–3 are HITL, 4–5 are what ralph does per ticket.

1. `/grill-with-docs`: align. Interactive.
2. `/to-spec`: write the spec. Skip if small.
3. Tickets: one forum post per vertical slice, tagged `Ready`. This is the hand-off: anything AFK must be a ticket.
4. Implement + 5. `/code-review`: one ralph iteration each ticket, fresh context every time, so the smart zone (<150k tokens) holds by construction.

Small things skip 1–3: write the post and tag it `Ready`.

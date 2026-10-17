---
name: ralph
description: How ralph, the AFK agent loop that works animal_island tickets from a Discord forum, operates, and how to file, read or update its tickets. Use when the user says "make that a ticket for ralph", "give this to ralph", "check ralph's tickets", "re-tag that Ready", or anything else about ralph or its Discord tickets.
---

# Ralph

Ralph is an unattended Claude Code loop. It runs inside the user's **webtop**, a podman container with a desktop, Godot, Blender and a browser. It turns Discord forum posts into commits on `main` of this repo. You run in a different place: a local checkout of `animal_island` on the host. Ralph has its own clone inside the container. The two of you share only GitHub `main` and the Discord forum.

Ralph's source lives in the user's `podman` repo at `~/code/vault/podman/webtop/ralph/`. You don't need to read it. This file covers what you need.

## How a ticket gets worked

1. Every 20 seconds the container checks the forum for a post tagged `Ready`. If there isn't one, nothing happens.
2. If there is one, ralph rebases its clone onto `origin/main`. **It sees only what has been pushed.** Your unpushed local commits and uncommitted edits don't exist for ralph.
3. A fresh headless `claude` session starts. It has no memory of earlier sessions. Its prompt holds the last 5 commits, the full text of every open ticket, and ralph's rules. For Godot repos it also gets a Godot section: it can run scenes, read debug output, take screenshots with Movie Maker and attach them to the ticket.
4. It picks **one** `Ready` ticket and tags it `Claimed`. It explores the code, uses TDD where there's a testable seam, runs the repo's checks and reviews its own diff. Then it makes **one commit on `main`** that references the post id, runs `git pull --rebase && git push`, and closes the ticket with a reply.
5. When several tickets are `Ready`, it picks in this order: critical bugfixes, then dev infrastructure (tests, tooling), then tracer-bullet feature slices, then polish and quick wins, then refactors. Ties go to the oldest post.

Ralph does one ticket per session, and it keeps context under about 150k tokens by design. When a ticket is too big, or ralph finds work outside its scope, it files new tickets tagged `Needs Info` for the user to review, and it doesn't do that work itself.

## The ticket system

The ticket tracker is a Discord **forum channel**, one per project. For animal_island the channel id is `1560465755219427348`. **One post is one ticket.** The post's title is the ticket title, its first message is the body, and replies in the post are the conversation. Ralph reads the whole thread, so a later reply can add to or correct the body.

**The post's single tag is its state:**

| Tag | Meaning | Who sets it |
| --- | --- | --- |
| `Ready` | An agent can finish it without asking anything. This is the only tag ralph picks up. | The user (or you, when asked) |
| `Blocked` | Waiting on another ticket, named by post id. Ralph re-tags it `Ready` once that ticket resolves. | Ralph or the user |
| `Claimed` | Ralph is working on it right now. If it stays stuck here, ralph died; re-tag it `Ready`. | Ralph |
| `Resolved` | Done. Ralph's reply says what it did. Questions and chat also end up here, answered. | Ralph |
| `Needs Info` | Ralph needs a decision, or hands only the user has. Its reply is the question. The user answers in the post and re-tags it `Ready`. Tickets ralph files itself also start here. | Ralph |

The loop works like this: the user or you writes a ticket and tags it `Ready`. Ralph claims it, then tags it `Resolved` or `Needs Info`. A `Needs Info` ticket goes back to the user, who answers and re-tags it `Ready`.

Special case: if the user's last message in a post contains `[%]`, ralph ends its `Resolved` reply with its context usage, for example `42k/150k (28%)`.

## The ticket tool

Use ralph's own script. It needs two env vars, `DISCORD_TOKEN` and `RALPH_CHANNEL`. The token is in the webtop's `.env`. Load only that one line, never the whole file, because the file holds other secrets:

```bash
R=~/code/vault/podman/webtop/ralph
export RALPH_CHANNEL=1560465755219427348
export DISCORD_TOKEN=$(grep '^DISCORD_TOKEN=' ~/code/vault/podman/webtop/.env | cut -d= -f2-)

$R/discord.sh tickets                       # every open (not Resolved) ticket with its messages: check before filing
$R/discord.sh ready                         # ids of Ready posts (exits non-zero if none)
$R/discord.sh create <tag> "<title>" "<body>"   # prints the new post id; title ≤100 chars, body ≤2000
$R/discord.sh tag <post id> <tag> ["reply"]     # change state, optionally replying in the post
$R/discord.sh attach <post id> <file> ["message"]  # screenshot, log, etc. (≤10 MB)
```

Tag names are case- and space-exact: `Ready`, `Blocked`, `Claimed`, `Resolved`, `Needs Info`. The commands print nothing on success and an error on failure, so you don't need to re-read the post to confirm. Never print or echo the token.

If the token can't be loaded (the file is missing or permission is denied), don't go looking for it elsewhere. Write out the title, tag and body for the user to paste into the forum.

## "Make that a ticket for ralph"

1. **Push first if the ticket depends on local work.** If the ticket builds on changes in this checkout, they must be on `origin/main` or ralph won't see them. Tell the user, and push only if they've authorized it. Ralph also commits to `main`, so expect to `git pull --rebase` locally afterwards.
2. **Check for duplicates** with `discord.sh tickets`. If a ticket already covers the work, add a reply to it with `tag <id> <its current tag> "..."` instead of filing a new one.
3. **Split by independent work.** Make one ticket per vertical slice that a fresh session can finish. If the work is big, file several tickets. Put a dependency in the dependent ticket's body as "Depends on <post id>". Create the dependency first so you have its id, and tag the dependent ticket `Blocked`.
4. **Write a body that stands alone.** Ralph starts with zero context: it never saw your conversation and doesn't know what "that" refers to. Include:
   - **What** to do, concretely.
   - **Why**: the goal or the bug's symptom, so ralph can make sensible calls.
   - **Where**: the relevant files, scenes (`res://...`), nodes and functions you already found. This saves ralph's context.
   - **Done when**: observable acceptance criteria, such as a scene that runs without errors, a test that passes, a screenshot that shows X, or an FPS level that holds.
   - Constraints or decisions already made with the user, so ralph doesn't reopen them.
   - Repro steps for a bug.
   Keep the body under 2000 characters. If more is needed, post the overflow as a reply with `tag <id> Ready "..."` right after creating the ticket.
5. **Pick the tag:**
   - `Ready` when the user asked for it and the ticket is fully specified with no open decisions. A user asking you to make a ticket is the hand-off.
   - `Needs Info` when a real decision is still open (end the body with that question), or when you're proposing the ticket rather than being asked for it.
   - `Blocked` when it waits on another unresolved ticket.
6. **Report back** the post id, title and tag. Mention that ralph will pick up a `Ready` ticket within about 20 seconds, as long as it isn't busy with another one.

### Example body

```
Player clips through the dock railing when sprinting diagonally.

Why: breaks the island boundary; players fall into the sea and soft-lock.
Where: scenes/world/dock.tscn (StaticBody3D "Railing", collision shape is a thin BoxShape3D),
player controller in scenes/player/player.gd (_physics_process, sprint speed 9.0).
Repro: run res://scenes/world/island.tscn, sprint into the railing at ~45°.
Done when: sprinting into the railing at any angle stops the player; attach a before/after
screenshot from the dock; no new errors in debug output.
Decided with user: thicken the collider, don't lower sprint speed.
```

## Other common asks

- **"What's ralph doing / what did it say?"**: run `discord.sh tickets`, or check `git log origin/main` after a `git fetch`. Ralph's commits reference post ids.
- **"Answer ralph" / "unblock that"**: `discord.sh tag <id> Ready "<the answer>"`.
- **A ticket stuck on `Claimed`** with no reply for a long time: ralph died mid-ticket. Re-tag it `Ready`.
- **Every `Ready` ticket suddenly turns `Needs Info` with a git error**: ralph's clone couldn't rebase onto `origin/main`, either because of a dirty tree, a conflict or a leftover rebase. The fix happens inside the webtop (`~/animal_island` there), not in your checkout. Tell the user.
- Don't edit ralph's scripts or prompt from here. They belong to the podman repo and get baked into the webtop image.

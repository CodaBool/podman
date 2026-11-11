# Game command service

Build a small HTTP service, the **cmd service**, that turns Discord slash commands into RCON calls for the game servers in this podman setup. A Cloudflare Worker calls it through the existing Cloudflare Tunnel, so the service never publishes a port to the host. It replaces an AWS Lambda that SSHed into this machine.

## Contract (shared with the Worker; change both sides together)

`POST /cmd` with header `X-Cmd-Secret: <CMD_SECRET>` and body `{ "cmd": string, "arg": string }`. Reply `200 { "ok": true, "output": string }`, or `4xx { "ok": false, "output": reason }`.

| `cmd` | `arg` rule | RCON sent |
|---|---|---|
| `minecraft_allowlist` | `^[A-Za-z0-9_]{3,16}$` | `whitelist add <arg>` to Minecraft |
| `factorio_allowlist` | `^[A-Za-z0-9_.-]{1,60}$` | `/whitelist add <arg>` to Factorio |
| `factorio_command` | any non-empty string, max 500 chars (the Worker only sends it for the admin) | `<arg>` as-is to Factorio |

## Steps

1. Read how the `itzg/minecraft-server` and Factorio containers are defined here (compose file, quadlets, or scripts), which network they share, and where their RCON passwords come from. Done when you can name the hostname, port, and password source for each RCON endpoint.
2. Write the cmd service in whichever language the repo already uses most. It speaks the Source RCON protocol directly over TCP. Install no game tooling. Validate `cmd` against the table and reject everything else. Done when every row in the table has a handler and every other input is rejected with a 4xx.
3. Run it as a container on the games' network with no host port, reading `CMD_SECRET` and the RCON passwords from the env/secret mechanism the repo already uses. Leave RCON unpublished too.
4. Route a tunnel hostname (for example `mc-cmd.<domain>`) to the service, in whatever way the repo already configures cloudflared. Write down the hostname for the Worker.
5. Verify: from another container on that network, `curl` each command with the right secret, then with a wrong secret and a bad `arg`. Done when all three cases return the expected status and the allowlist change is visible in game.

Leave the Cloudflare Access service-token policy on the hostname to the owner (dashboard step), and list it as a follow-up.

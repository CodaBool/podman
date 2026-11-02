# AGENTS.md

Podman quadlets for one self-hosted server, plus the custom images some of them run. `readme.md` covers the host setup and lists the services.

## How it deploys

- The server keeps a checkout of this repo at `~/.config/containers/systemd/`. Every `*.container` / `*.network` file there, in any subdirectory, becomes a user systemd service. The server is a different machine; this checkout is only for editing.
- **Pushing to `main` deploys.** CI (`.github/workflows/build.yml`) rebuilds and pushes `ghcr.io/codabool/webtop` and `ghcr.io/codabool/brave` `:latest` on every push. The server pulls new images with `podman auto-update` every day (`AutoUpdate=registry`). Commit or push only when asked.
- `vault/` holds retired quadlets. Their files have no extension, so quadlet ignores them. To bring a service back, move it out and add `.container`. To retire one, move it into `vault/` and drop the extension.
- Secrets live on the server in `/mnt/volumes/.<name>.env`, read through `EnvironmentFile=`. The repo never holds them. List the variable names in a comment when you add one, as `tunnel.container` does. Persistent data lives in `/mnt/volumes/<name>`.

## Writing a quadlet

Copy a nearby file and keep its trailer: `AutoUpdate=registry`, `TimeoutStartSec=900`, `Restart=always`, `WantedBy=default.target`. A multi-container stack gets its own directory with `<stack>.network` (`NetworkName=%N`, a unique `/24` subnet). Each member sets `Network=<stack>-network` plus `Requires=` and `After=` on `<stack>-network.service`. See `ai/`.

Validate from the repo root. This needs no server. The `permission denied` lines come from the gitignored `webtop/config/` and are noise:

```sh
QUADLET_UNIT_DIRS=$PWD /usr/libexec/podman/quadlet -dryrun -user 2>&1 | grep -v 'permission denied'
```

Every unit should appear as `---<name>.service---`. The run always ends with `processing encountered some errors`, which comes from the same unreadable files; any other error is real.

## webtop and brave images

Both images are linuxserver webtop images. webtop is Arch with sway, Godot and Blender, and ralph. brave is Fedora KDE with Hermes. Their PID 1 is **s6**, not systemd. Know which files reach the server, and how:

- `Dockerfile`, `s6/` and `webtop/ralph/` are baked into the image. They reach the server only after a push to `main` and the next auto-update.
- `init.sh` is bind-mounted from the server's checkout. It runs as root on every container start. Write it to be idempotent, because `/config` persists between starts.
- A new s6 service needs `run`, `type`, `dependencies.d/` like its siblings, plus a `touch .../user/contents.d/<svc>` line in the Dockerfile. Without that line the service never starts.
- Each `justfile` is for local testing. Its `run` recipe uses an NVIDIA device; the quadlet uses the server's AMD `/dev/dri`. Reconcile the two by hand.

## ralph

`webtop/ralph/` is an AFK Claude Code loop that turns Discord forum tickets into commits. `webtop/ralph/README.md` documents every script. `webtop/SKILL.md` is the skill that sessions in *other* repos install to file ralph tickets, and the single source for the ticket lifecycle and signals. When you change a `discord.sh` command or the lifecycle, update `SKILL.md`, the README's script table, and `ralph/prompt.md` if ralph's own behaviour changes.

# remove brave's and the agents' Chromium's safety locks: a new container's hostname makes them look held by another computer
rm -f ~/.config/BraveSoftware/Brave-Browser/SingletonLock ~/.config/chromium/SingletonLock

# AI CLIs signed in with subscriptions from the env file. Runs as root on every start; /config persists.
# Claude Code reads CLAUDE_CODE_OAUTH_TOKEN (`claude setup-token`) itself; just skip its first-run wizard.
# Skip Claude Code onboarding without replacing existing config
python3 - <<'PY'
import json
from pathlib import Path

p = Path("/config/.claude.json")
data = json.loads(p.read_text()) if p.exists() else {}

if data.get("hasCompletedOnboarding") is not True:
    data["hasCompletedOnboarding"] = True
    p.write_text(json.dumps(data, indent=2) + "\n")
PY

chown abc:abc /config/.claude.json
chmod 600 /config/.claude.json

# Git as abc: push to GitHub over HTTPS with GITHUB_TOKEN, read at push time so it's never stored on disk.
gc() { s6-setuidgid abc git config --global "$@"; }
gc user.name > /dev/null || gc user.name CodaBool
gc user.email > /dev/null || gc user.email CodaBool@pm.me
gc push.autoSetupRemote true
gc pull.rebase false  # trunk on main: replay local commits onto what was pushed, never merge commits
[ -z "$GITHUB_TOKEN" ] || gc credential.https://github.com.helper \
  '!f() { echo username=x-access-token; echo "password=$GITHUB_TOKEN"; }; f'

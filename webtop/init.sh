# remove brave's and the agents' Chromium's safety locks: a new container's hostname makes them look held by another computer
rm -f ~/.config/BraveSoftware/Brave-Browser/SingletonLock ~/.config/ralph/chromium/SingletonLock

# AI CLIs signed in with subscriptions from the env file. Runs as root on every start; /config persists.
# Claude Code reads CLAUDE_CODE_OAUTH_TOKEN (`claude setup-token`) itself; just skip its first-run wizard.
if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ] && [ ! -f ~/.claude.json ]; then
  echo '{"hasCompletedOnboarding": true}' > ~/.claude.json
  chown abc:abc ~/.claude.json
fi
# The agents' browser (ralph/browser.sh) as a user-scope MCP server, so every Claude session has it, ralph's included.
# Tool search keeps it cheap: only tool names are in context until one is needed. cat keeps the file's owner and mode.
[ -s ~/.claude.json ] || { echo '{}' > ~/.claude.json; chown abc:abc ~/.claude.json; }
json=$(jq '.mcpServers.browser = {type: "stdio", command: "/opt/ralph/browser.sh", args: ["mcp"]}' ~/.claude.json) \
  && cat <<< "$json" > ~/.claude.json
# Codex: seed its ChatGPT sign-in once from CODEX_AUTH_JSON (base64 of an auth.json); codex refreshes it in /config after that.
if [ -n "$CODEX_AUTH_JSON" ] && [ ! -f ~/.codex/auth.json ]; then
  mkdir -p ~/.codex
  base64 -d <<< "$CODEX_AUTH_JSON" > ~/.codex/auth.json
  chmod 600 ~/.codex/auth.json
  chown -R abc:abc ~/.codex
fi

# Git as abc: push to GitHub over HTTPS with GITHUB_TOKEN, read at push time so it's never stored on disk.
gc() { s6-setuidgid abc git config --global "$@"; }
gc user.name > /dev/null || gc user.name CodaBool
gc user.email > /dev/null || gc user.email CodaBool@pm.me
gc push.autoSetupRemote true
[ -z "$GITHUB_TOKEN" ] || gc credential.https://github.com.helper \
  '!f() { echo username=x-access-token; echo "password=$GITHUB_TOKEN"; }; f'

# Ralph projects, the source of truth for ~/.config/ralph/projects.conf (rewritten every start).
# One project per line: <git url> <discord forum channel id> <agent>. agent is claude for now.
# Each repo is cloned to ~/<repo name> if it isn't there yet; existing clones are left alone, so unpushed work survives.
projects=(
  "https://github.com/CodaBool/animal_island 1560465755219427348 claude"
)
install -d -o abc -g abc ~/.config ~/.config/ralph
for p in "${projects[@]}"; do  # only the conf lines go to stdout
  read -r url channel agent <<< "$p"
  repo=~/$(basename "$url" .git)
  [ -d "$repo/.git" ] || s6-setuidgid abc git clone -q "$url" "$repo" >&2 || echo "ralph: cloning $url failed, retried next start" >&2
  echo "$repo $channel $agent"
done | s6-setuidgid abc tee ~/.config/ralph/projects.conf > /dev/null

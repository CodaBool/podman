#!/bin/bash
# Brings the current branch up to date with its upstream before an agent works on it: local commits are rebased onto what was pushed.
# Exits 1, leaving the repo as it was, when it can't: a failed fetch (likely transient) is only logged; a dirty tree, rebase conflict or leftover rebase
# also tags every Ready ticket Needs Info with the reason, so you hear about it once instead of every tick. Run from the project root.
dir=$(dirname "$(realpath "$0")")
export GIT_TERMINAL_PROMPT=0

# An agent that died mid-rebase leaves HEAD detached (so no upstream either): report it rather than abort its work or build on it
if [ -d "$(git rev-parse --git-path rebase-merge)" ] || [ -d "$(git rev-parse --git-path rebase-apply)" ]; then
  out="A rebase is already in progress (an agent likely died resolving a conflict). Finish it with \`git rebase --continue\` or drop it with \`git rebase --abort\`."
else
  git rev-parse -q --verify '@{u}' > /dev/null || exit 0  # no upstream, nothing to pull
  git fetch -q || { echo "sync: fetch failed, retrying next tick"; exit 1; }
  [ "$(git rev-list --count 'HEAD..@{u}')" = 0 ] && exit 0  # nothing new, so local edits don't matter
  out=$(git rebase -q '@{u}' 2>&1) && exit 0
  git rebase --abort 2> /dev/null
fi
echo "sync: $out"
msg="Can't bring $(basename "$PWD") up to date with GitHub on the webtop, so I haven't started:
\`\`\`
${out:0:1500}
\`\`\`
Fix it in a webtop terminal (\`cd ~/$(basename "$PWD")\`), then re-tag this Ready."
"$dir/discord.sh" ready | while read -r post; do "$dir/discord.sh" tag "$post" 'Needs Info' "$msg"; done
exit 1

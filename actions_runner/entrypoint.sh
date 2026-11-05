#!/usr/bin/env bash
# Registers an ephemeral GitHub Actions runner, takes one job, then exits.
# systemd restarts the unit and quadlet's --rm gives the next job a fresh container.
set -euo pipefail

: "${GH_PAT:?set GH_PAT in /mnt/volumes/.actions_runner.env}"
: "${GH_REPO:?set Environment=GH_REPO=owner/name in the .container}"

# registration tokens live 1h, so mint a new one on every start
REG_TOKEN=$(curl -fsSL -X POST \
  -H "Authorization: Bearer ${GH_PAT}" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/${GH_REPO}/actions/runners/registration-token" | jq -r .token)

# the job never needs the PAT
unset GH_PAT

./config.sh --unattended \
  --url "https://github.com/${GH_REPO}" \
  --token "${REG_TOKEN}" \
  --name selfhost \
  --ephemeral \
  --replace \
  --disableupdate

unset REG_TOKEN
exec ./run.sh

#!/usr/bin/env bash
# Registers an ephemeral GitHub Actions runner, takes one job, then exits.
# systemd restarts the unit and quadlet's --rm gives the next job a fresh container.
set -euo pipefail

: "${GH_PAT:?set GH_PAT in /mnt/volumes/.actions_runner.env}"
: "${GH_REPO:?set Environment=GH_REPO=owner/name in the .container}"
: "${PODMAN_VERSION:?set Environment=PODMAN_VERSION in the .container}"

# static podman-remote client for jobs; it drives the host's podman over CONTAINER_HOST
PODMAN_URL="https://github.com/containers/podman/releases/download/v${PODMAN_VERSION}"
cd /tmp
curl -fsSLO "${PODMAN_URL}/podman-remote-static-linux_amd64.tar.gz"
curl -fsSL "${PODMAN_URL}/shasums" | grep ' podman-remote-static-linux_amd64.tar.gz$' | sha256sum -c -
tar -xzf podman-remote-static-linux_amd64.tar.gz --strip-components=1
sudo install -m 755 podman-remote-static-linux_amd64 /usr/local/bin/podman
rm -f podman-remote-static-linux_amd64*
cd - >/dev/null
podman version --format 'podman client {{.Client.Version}}, server {{.Server.Version}}'

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

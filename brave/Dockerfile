
FROM lscr.io/linuxserver/webtop:fedora-kde

# Install system packages
RUN dnf upgrade --refresh -y \
    && dnf install -y \
    nodejs-npm \
    gimp \
    unzip \
  && dnf clean all

# /usr/bin/chromium-browser
LABEL org.opencontainers.image.source="https://github.com/CodaBool/podman"

# Install Brave Browser
RUN dnf config-manager addrepo \
    --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo \
    && dnf install -y brave-browser \
    && dnf clean all

# Install Claude Code
RUN printf '%s\n' \
    '[claude-code]' \
    'name=Claude Code' \
    'baseurl=https://downloads.claude.ai/claude-code/rpm/stable' \
    'enabled=1' \
    'gpgcheck=1' \
    'gpgkey=https://downloads.claude.ai/keys/claude-code.asc' \
    > /etc/yum.repos.d/claude-code.repo \
    && dnf install -y claude-code \
    && dnf clean all

# Install latest Obsidian
RUN set -eux; \
    VERSION=$(curl -fsSL https://raw.githubusercontent.com/obsidianmd/obsidian-releases/master/desktop-releases.json \
      | python3 -c 'import json,sys; print(json.load(sys.stdin)["latestVersion"])'); \
    mkdir -p /opt/obsidian; \
    curl -fsSL \
      "https://github.com/obsidianmd/obsidian-releases/releases/download/v${VERSION}/obsidian-${VERSION}.tar.gz" \
      -o /tmp/obsidian.tar.gz; \
    tar -xzf /tmp/obsidian.tar.gz -C /opt/obsidian --strip-components=1; \
    rm /tmp/obsidian.tar.gz; \
    printf '#!/bin/sh\nexec /opt/obsidian/obsidian --no-sandbox "$@"\n' > /usr/local/bin/obsidian; \
    chmod +x /usr/local/bin/obsidian

FROM lscr.io/linuxserver/webtop:fedora-kde

# Install system packages
RUN dnf upgrade --refresh -y \
    && dnf install -y \
    nodejs-npm \
    gimp \
    kate \
    unzip \
    dejavu-sans-fonts \
    google-noto-sans-symbols-fonts \
    google-noto-symbols2-fonts \
  && dnf clean all

LABEL org.opencontainers.image.source="https://github.com/CodaBool/podman"

# Brave Browser
RUN dnf config-manager addrepo \
    --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo \
    && dnf install -y brave-browser \
    && dnf clean all

# Claude Code
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

# Obsidian
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

# Obsidian launcher
RUN mkdir -p /usr/share/pixmaps \
    && curl -fsSL https://obsidian.md/images/obsidian-logo-gradient.svg \
      -o /usr/share/pixmaps/obsidian.svg \
    && printf '%s\n' \
      '[Desktop Entry]' \
      'Name=Obsidian' \
      'Exec=/usr/local/sbin/obsidian %U' \
      'Icon=/usr/share/pixmaps/obsidian.svg' \
      'Type=Application' \
      'Terminal=false' \
      'Categories=Office;TextEditor;Utility;' \
      'StartupWMClass=obsidian' \
      > /usr/share/applications/obsidian.desktop

# Hermes
RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh \
    | bash -s -- --non-interactive --dir /opt/hermes-agent \
    && ln -sf /opt/hermes-agent/venv/bin/hermes /usr/local/bin/hermes \
    && chmod -R a+rX /opt/hermes-agent

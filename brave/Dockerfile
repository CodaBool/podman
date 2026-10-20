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
    google-noto-sans-symbols-2-fonts \
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

# Hermes, installed in the image under /opt/hermes: its Python in tools/, its packages in installs/.
# Both default to $HERMES_HOME, which the /config volume would hide, so init.sh links installs/ into it.
# Owned by abc (PUID 1000): hermes locks and updates its install state on every launch.
ENV HERMES_RUNTIME_DIR=/opt/hermes/tools
RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh \
    | HERMES_HOME=/opt/hermes bash -s -- --non-interactive --dir /opt/hermes/hermes-agent \
    && ln -sf /opt/hermes/hermes-agent/.hermes/bin/hermes /usr/local/bin/hermes \
    && chown -R 1000:1000 /opt/hermes

# Hermes gateway and dashboard as s6 services (PID 1 is s6, not systemd), run as abc. Logs go to `podman logs`.
# State in abc's persistent /config, hermes' default ~/.hermes; init.sh seeds it on first start.
ENV HERMES_HOME=/config/.hermes
COPY s6/ /etc/s6-overlay/s6-rc.d/
RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/svc-hermes-gateway \
          /etc/s6-overlay/s6-rc.d/user/contents.d/svc-hermes-dashboard

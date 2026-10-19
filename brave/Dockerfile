
FROM lscr.io/linuxserver/webtop:fedora-kde

# Install system packages
RUN dnf upgrade --refresh -y \
    && dnf install -y \
    nano \
    firefox \
    gimp \
    nodejs \
    python3-pip \
    && dnf clean all

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

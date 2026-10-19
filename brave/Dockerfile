
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

# Install Brave Browser
RUN dnf config-manager addrepo \
    --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo \
    && dnf install -y brave-browser \
    && dnf clean all

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && cp /root/.local/bin/claude /usr/local/bin/claude

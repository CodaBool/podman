# https://github.com/linuxserver/docker-webtop
FROM lscr.io/linuxserver/webtop:arch-i3

# Install system packages
RUN pacman -Syu --noconfirm --needed \
    base-devel \
    git \
    curl \
    nano \
    godot \
    blender \
    python \
    python-pip \
    nodejs \
    grep \
    npm \
    vim \
    unzip \
    ripgrep \
    tmux \
    && pacman -Scc --noconfirm

# Build Brave from the AUR as a temporary non-root user
RUN useradd -m builder \
    && echo 'builder ALL=(ALL) NOPASSWD: /usr/bin/pacman' > /etc/sudoers.d/builder \
    && chmod 440 /etc/sudoers.d/builder \
    && su builder -c '\
       cd ~ && \
       git clone https://aur.archlinux.org/brave-bin.git && \
       cd brave-bin && \
       makepkg -s --noconfirm' \
    && pacman -U --noconfirm /home/builder/brave-bin/brave-bin-*.pkg.tar.zst \
    && rm -f /etc/sudoers.d/builder \
    && userdel -r builder \
    && pacman -Scc --noconfirm

# Install AI coding agents system-wide
RUN npm install -g \
    @anthropic-ai/claude-code \
    @openai/codex \
    && npm cache clean --force

# System-wide Bash defaults (Arch Linux)
# Doesn't get hidden by Webtop's persistent /config volume
RUN cat >> /etc/bash.bashrc <<'EOF'

# Development environment
export EDITOR=nano
export PATH="$HOME/.local/bin:$PATH"

alias ll='ls -lah'
EOF

# Disable i3 first-run wizard and set Alt as modifier
RUN mkdir -p /etc/xdg/i3 \
    && sed -e 's/^set \$mod .*/set $mod Mod1/' \
           -e '/^exec i3-config-wizard/d' \
       /etc/i3/config > /etc/xdg/i3/config

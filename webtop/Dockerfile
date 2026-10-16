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
    jq \
    util-linux \
    xorg-server-xvfb \
    vulkan-radeon \
    vulkan-swrast \
    wmenu \
    grim \
    slurp \
    chromium \
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

# Install AI coding agents and MCP servers system-wide
# MCP servers are installed rather than npx'd: an npx download on first use outlasts Claude's MCP connect timeout
# chrome-devtools-mcp bundles puppeteer-core and attaches to the system Chromium (ralph/browser.sh), so no browser download
RUN npm install -g --allow-scripts=@anthropic-ai/claude-code \
    @anthropic-ai/claude-code \
    @openai/codex \
    @coding-solo/godot-mcp \
    chrome-devtools-mcp \
    && npm cache clean --force

# System-wide Bash defaults (Arch Linux)
# Doesn't get hidden by Webtop's persistent /config volume
RUN cat >> /etc/bash.bashrc <<'EOF'

# Development environment
export EDITOR=nano
export PATH="$HOME/.local/bin:$PATH"

alias log='tail -F ~/.local/state/ralph/animal_island.log'
alias ll='ls -lah'
EOF


# TODO: cant seem to replace icon
# COPY ./rat.png /usr/share/selkies/www/icon.png

# Alt as modifier. PIXELFLUX_WAYLAND=true runs sway (/etc/sway/config); i3 is only used without it.
# sway expands $mod as each binding is read, so it's changed in place rather than overridden from config.d
RUN mkdir -p /etc/xdg/i3 \
    && sed -e 's/^set \$mod .*/set $mod Mod1/' \
           -e '/^exec i3-config-wizard/d' \
       /etc/i3/config > /etc/xdg/i3/config \
    && sed -i 's/^set \$mod .*/set $mod Mod1/' /etc/sway/config

# Ralph: Discord-forum ticket loop, ticked every minute by an s6 service (PID 1 is s6, not systemd)
# Projects are listed in init.sh, which writes /config/.config/ralph/projects.conf and clones them, logs in /config/.local/state/ralph/
COPY ralph/ /opt/ralph/
COPY s6/ /etc/s6-overlay/s6-rc.d/
RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/svc-ralph \
    && chmod -R a-w,a+rX /opt/ralph \
    && chmod a+x /opt/ralph/*.sh

# Disable the unsafe paste dialog in xfce4-terminal for the default container user (abc) and skel
# TODO: this didn't seem to work to remove the dialog
#RUN mkdir -p /config/.config/xfce4/terminal /etc/skel/.config/xfce4/terminal && \
#    echo '[Configuration]' >> /config/.config/xfce4/terminal/terminalrc && \
#    echo 'MiscShowUnsafePasteDialog=FALSE' >> /config/.config/xfce4/terminal/terminalrc && \
#    cp /config/.config/xfce4/terminal/terminalrc /etc/skel/.config/xfce4/terminal/terminalrc && \
#    chown -R 1000:1000 /config/.config/xfce4

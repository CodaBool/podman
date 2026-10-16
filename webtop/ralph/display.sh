#!/bin/bash
# Runs a command on a display: the webtop's sway desktop when it's up, else a private Xvfb.
#   display.sh <command> [args...]
# The image's DISPLAY=:1 is the Xvfb that PIXELFLUX_WAYLAND mode never starts, and s6 services (svc-ralph) don't get sway's env,
# so this finds the live sockets instead of trusting the env. On sway, Vulkan and OpenGL (via Xwayland) both render on the GPU.
set -eo pipefail
[ -n "$1" ] || { echo "usage: display.sh <command> [args...]" >&2; exit 1; }
run=${XDG_RUNTIME_DIR:-$HOME/.XDG}

# sway's Wayland socket. wayland-1 is pixelflux's compositor, which sway nests in.
if [ -z "$WAYLAND_DISPLAY" ] || [ "$WAYLAND_DISPLAY" = wayland-1 ] || [ ! -S "$run/$WAYLAND_DISPLAY" ]; then
  unset WAYLAND_DISPLAY
  for s in "$run"/wayland-*; do
    [ -S "$s" ] && [ "${s##*/}" != wayland-1 ] && { export WAYLAND_DISPLAY=${s##*/}; break; }
  done
fi
# sway's Xwayland socket (it starts Xwayland on the first connection)
d=${DISPLAY#:}
if [ -z "$DISPLAY" ] || [ ! -S "/tmp/.X11-unix/X${d%%.*}" ]; then
  unset DISPLAY
  for s in /tmp/.X11-unix/X*; do
    [ -S "$s" ] && { export DISPLAY=:${s##*/X}; break; }
  done
fi

[ -n "$WAYLAND_DISPLAY$DISPLAY" ] && exec "$@"
exec xvfb-run -a -s '-screen 0 1920x1080x24' "$@"  # no desktop: OpenGL is llvmpipe here, Vulkan still finds the GPU

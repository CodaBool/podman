#!/bin/bash
# The agents' Chromium: its own profile, a debugging port on localhost, kept running between sessions so tabs and logins persist
# and you can watch or drive the same window in the stream.
#   browser.sh            starts it unless it's up: on the sway desktop through display.sh, or headless with BROWSER_HEADLESS=1
#   browser.sh mcp [...]  starts it, then runs chrome-devtools-mcp attached to it (the `browser` server in mcp.json)
# Whichever mode starts it first wins: BROWSER_HEADLESS is ignored while a browser is already on the port.
set -eo pipefail
dir=$(dirname "$(realpath "$0")")
url=http://127.0.0.1:9222
up() { curl -sf "$url/json/version" > /dev/null; }

if ! up; then
  log=$HOME/.local/state/ralph/browser.log; mkdir -p "${log%/*}"
  # Not Brave's profile, so the agent's cookies, logins and extensions stay out of yours. Persists in /config.
  flags=(--user-data-dir="$HOME/.config/ralph/chromium" --remote-debugging-port=9222
         --no-first-run --no-default-browser-check --ignore-gpu-blocklist)
  if [ -n "$BROWSER_HEADLESS" ]; then
    # Headless WebGL is off or SwiftShader by default; ANGLE on EGL renders on the GPU through /dev/dri (ANGLE on Vulkan wants an X server)
    cmd=(/usr/lib/chromium/chromium --headless --use-angle=gl-egl)
  else
    # Native Wayland on sway (--ozone-platform-hint=auto still picks Xwayland), X11 under display.sh's Xvfb fallback
    cmd=("$dir/display.sh" bash -c 'exec /usr/lib/chromium/chromium --ozone-platform=$([ -n "$WAYLAND_DISPLAY" ] && echo wayland || echo x11) "$@"' _)
  fi
  setsid "${cmd[@]}" "${flags[@]}" < /dev/null >> "$log" 2>&1 &  # own session: outlives the MCP server and the agent
  for _ in {1..100}; do up && break; sleep 0.1; done
  up || { echo "chromium didn't open $url, see $log" >&2; tail -5 "$log" >&2; exit 1; }
fi
[ "$1" != mcp ] || exec chrome-devtools-mcp --browserUrl "$url" --workspace=/ --no-usage-statistics --no-performance-crux "${@:2}"

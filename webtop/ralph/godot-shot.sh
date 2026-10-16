#!/bin/bash
# Renders a Godot scene for some frames with Movie Maker and prints the path of a PNG of the last one. Run inside the repo.
#   godot-shot.sh <scene> [frames] [extra godot args, e.g. --rendering-driver opengl3]
# Runs on the webtop's sway desktop (GPU via RADV) through display.sh, or a private Xvfb when the desktop isn't up.
set -eo pipefail
dir=$(dirname "$(realpath "$0")")
scene=${1:?usage: godot-shot.sh <scene> [frames] [godot args...]}; frames=${2:-60}
fail() { echo "$1" >&2; [ -z "$2" ] || tail -20 "$2" >&2; exit 1; }  # stderr, so png=$(godot-shot.sh ...) never captures an error
proj=$(find . -path '*/.*' -prune -o -name project.godot -print -quit)
[ -n "$proj" ] || fail "no project.godot under $PWD"; root=$(dirname "$proj")
out=${TMPDIR:-/tmp}/ralph-shots; mkdir -p "$out"
# Discord keeps the copy that matters; locally keep a day's worth. Also sweeps frame dirs left by a killed run.
find "$out" -mindepth 1 -maxdepth 1 -mmin +1440 -exec rm -rf {} +
tmp=$(mktemp -d "$out/.frames-XXXXXX"); trap 'rm -rf "$tmp"' EXIT

# Import first: a fresh clone has no .godot/ cache, so new or never-imported assets would render missing
timeout 300 godot --headless --path "$root" --import > "$tmp/import.log" 2>&1 || fail "import failed:" "$tmp/import.log"
timeout 300 "$dir/display.sh" godot --path "$root" --write-movie "$tmp/f.png" --fixed-fps 30 --quit-after "$frames" "${@:3}" "$scene" \
  > "$tmp/run.log" 2>&1 || fail "run failed:" "$tmp/run.log"
last=$(ls "$tmp"/f*.png 2>/dev/null | tail -1)
[ -n "$last" ] || fail "no frames rendered:" "$tmp/run.log"
grep -m1 "Using Device" "$tmp/run.log" >&2 || true  # which GPU drew it, e.g. "AMD Radeon RX 7600 (RADV NAVI33)" vs llvmpipe
png=$(mktemp --suffix=.png "$out/$(basename "${scene%.*}")-$(date +%Y%m%d-%H%M%S)-XXXX")  # unique even for repeat shots
mv "$last" "$png"; echo "$png"

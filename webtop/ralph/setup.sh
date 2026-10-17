#!/bin/bash
# Runs the project's own setup hook, an executable tools/setup.sh (deps, venvs, generated files), from the project root, capped at 5 minutes.
# The hook should be idempotent and fast when nothing changed; it runs before every session and may use the network, so the session needn't.
# Its output goes to stderr (the log). On failure this prints a short warning on stdout for context.sh, and still exits 0: the ticket goes ahead.
hook=tools/setup.sh
[ -x "$hook" ] || exit 0
tmp=$(mktemp); trap 'rm -f "$tmp"' EXIT
timeout -k 10 300 "$hook" < /dev/null 2>&1 | tee "$tmp" >&2
code=${PIPESTATUS[0]}
[ "$code" = 0 ] && exit 0
case $code in 124|137) why="timed out after 5 minutes" ;; *) why="exited $code" ;; esac
echo "setup: $hook $why" >&2
echo "The project's setup hook \`$hook\` $why before this session, so your environment may be incomplete (missing deps, skipped checks). Its last lines:"
echo '```'; tail -n 10 "$tmp"; echo '```'
exit 0

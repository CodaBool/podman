#!/bin/bash
# Discord forum as the ticket tracker: one post per ticket, its tag is its state. Needs DISCORD_TOKEN and RALPH_CHANNEL.
#   discord.sh ready                    prints the ids of posts tagged Ready, exits 1 when there are none
#   discord.sh tickets                  prints every post not tagged Resolved, with its messages
#   discord.sh tickets --ready-full     same, but only Ready posts get their messages; the rest get one line with any "Depends on" lines from the body
#   discord.sh tag <post> <tag> [reply] sets the post's tag (Ready, Blocked, Needs Info, Claimed, Resolved), then replies
#   discord.sh attach <post> <file> [message] posts a file (screenshot, log) in the post, up to 10 MB
#   discord.sh create <tag> <title> <body> opens a post with that tag and prints its id; title up to 100 chars, body up to 2000
#   discord.sh effort                   prints the highest effort (medium, high, xhigh, max) the Ready posts ask for: a signal like [high] or [%,max] in the human's last message
set -eo pipefail
: "${DISCORD_TOKEN:?}" "${RALPH_CHANNEL:?}"
api() { curl -sSf -H "Authorization: Bot $DISCORD_TOKEN" -H 'Content-Type: application/json' "https://discord.com/api/v10$1" "${@:2}"; }
forum=$(api "/channels/$RALPH_CHANNEL")
tag_id() { jq -er --arg n "$1" '.available_tags[] | select(.name == $n).id' <<< "$forum" || { echo "no tag named '$1'" >&2; exit 1; }; }

# Active and archived posts (idle posts auto-archive), one JSON line each: {id, name, tags: [names]}.
posts() {
  { api "/guilds/$(jq -r .guild_id <<< "$forum")/threads/active" | jq --arg c "$RALPH_CHANNEL" '.threads[] | select(.parent_id == $c)'
    api "/channels/$RALPH_CHANNEL/threads/archived/public?limit=100" | jq '.threads[]'
  } | jq -c --argjson f "$forum" '{id, name, tags: [.applied_tags[] as $t | $f.available_tags[] | select(.id == $t).name]}'
}

case $1 in
  ready) posts | jq -er 'select(.tags | index("Ready")).id' ;;
  tickets)
    posts | jq -c 'select(.tags | index("Resolved") | not)' | while read -r p; do
      head=$(jq -r '"## POST \(.id): \(.name) [\(.tags | join(", "))]"' <<< "$p")
      if [ "$2" = --ready-full ] && ! jq -e '.tags | index("Ready")' <<< "$p" > /dev/null; then
        # A forum post's starter message shares the post's id
        deps=$(api "/channels/$(jq -r .id <<< "$p")/messages/$(jq -r .id <<< "$p")" |
          jq -r '[.content | splits("\n") | select(test("depends on"; "i"))] | join("; ")') || deps=""
        echo "$head${deps:+ $deps}"; continue
      fi
      echo "$head"
      api "/channels/$(jq -r .id <<< "$p")/messages?limit=100" | jq -r 'reverse[] | "\(.author.username): \(.content)\n"'
    done ;;
  tag)
    id=$(tag_id "$3")
    jq -n --arg t "$id" '{archived: false, applied_tags: [$t]}' | api "/channels/$2" -X PATCH -d @- > /dev/null
    [ -z "$4" ] || jq -n --arg c "$4" '{content: $c}' | api "/channels/$2/messages" -d @- > /dev/null ;;
  attach)
    [ -f "$3" ] || { echo "no file '$3'"; exit 1; }
    curl -sSf -H "Authorization: Bot $DISCORD_TOKEN" -F "payload_json=$(jq -n --arg c "$4" '{content: $c}')" \
      -F "files[0]=@$3" "https://discord.com/api/v10/channels/$2/messages" > /dev/null ;;
  create)
    id=$(tag_id "$2")
    [ -n "$3" ] && [ ${#3} -le 100 ] || { echo "title must be 1-100 chars"; exit 1; }
    [ -n "$4" ] && [ ${#4} -le 2000 ] || { echo "body must be 1-2000 chars"; exit 1; }
    jq -n --arg t "$id" --arg n "$3" --arg c "$4" '{name: $n, applied_tags: [$t], message: {content: $c}}' |
      api "/channels/$RALPH_CHANNEL/threads" -d @- | jq -r .id ;;
  effort)
    posts | jq -r 'select(.tags | index("Ready")).id' | while read -r id; do
      api "/channels/$id/messages?limit=100" | jq -r '([.[] | select(.author.bot | not)][0].content // "")
        | [scan("\\[([^]]*)\\]")[0] | splits(",") | gsub("\\s"; "")] as $s
        | first(("max", "xhigh", "high") | select(IN($s[]))) // "medium"'
    done | awk 'BEGIN { r["high"] = 1; r["xhigh"] = 2; r["max"] = 3; best = "medium" } r[$1] > r[best] { best = $1 } END { print best }' ;;
  *) sed -n '2,9p' "$0"; exit 1 ;;
esac

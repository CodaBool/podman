#!/bin/bash
# Discord forum as the ticket tracker: one post per ticket, its tag is its state. Needs DISCORD_TOKEN and RALPH_CHANNEL.
#   discord.sh ready                    exits 0 when a post is tagged Ready
#   discord.sh tickets                  prints every post not tagged Resolved, with its messages
#   discord.sh tag <post> <tag> [reply] sets the post's tag (Ready, Blocked, Needs Info, Claimed, Resolved), then replies
set -eo pipefail
: "${DISCORD_TOKEN:?}" "${RALPH_CHANNEL:?}"
api() { curl -sSf -H "Authorization: Bot $DISCORD_TOKEN" -H 'Content-Type: application/json' "https://discord.com/api/v10$1" "${@:2}"; }
forum=$(api "/channels/$RALPH_CHANNEL")

# Active and archived posts (idle posts auto-archive), one JSON line each: {id, name, tags: [names]}.
posts() {
  { api "/guilds/$(jq -r .guild_id <<< "$forum")/threads/active" | jq --arg c "$RALPH_CHANNEL" '.threads[] | select(.parent_id == $c)'
    api "/channels/$RALPH_CHANNEL/threads/archived/public?limit=100" | jq '.threads[]'
  } | jq -c --argjson f "$forum" '{id, name, tags: [.applied_tags[] as $t | $f.available_tags[] | select(.id == $t).name]}'
}

case $1 in
  ready) posts | jq -e 'select(.tags | index("Ready"))' > /dev/null ;;
  tickets)
    posts | jq -c 'select(.tags | index("Resolved") | not)' | while read -r p; do
      jq -r '"## POST \(.id): \(.name) [\(.tags | join(", "))]"' <<< "$p"
      api "/channels/$(jq -r .id <<< "$p")/messages?limit=100" | jq -r 'reverse[] | "\(.author.username): \(.content)\n"'
    done ;;
  tag)
    id=$(jq -r --arg n "$3" '.available_tags[] | select(.name == $n).id' <<< "$forum")
    [ -n "$id" ] || { echo "no tag named '$3'"; exit 1; }
    jq -n --arg t "$id" '{archived: false, applied_tags: [$t]}' | api "/channels/$2" -X PATCH -d @- > /dev/null
    [ -z "$4" ] || jq -n --arg c "$4" '{content: $c}' | api "/channels/$2/messages" -d @- > /dev/null ;;
  *) sed -n '2,5p' "$0"; exit 1 ;;
esac

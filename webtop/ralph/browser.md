
# BROWSER

The `browser` MCP server (chrome-devtools-mcp) drives a Chromium with its own profile, on the webtop desktop where the human can watch and may be using it too. Open your own tab with `new_page` instead of navigating theirs, and close it when you're done.

Use it whenever the work touches something a browser shows: check a web UI after a change, reproduce a ticket's bug, read a page a ticket links, or docs that need JavaScript. Read pages with `take_snapshot` (the accessibility tree, with the uids `click` and `fill` take) and `evaluate_script` for anything it leaves out. Check `list_console_messages` and `list_network_requests` for errors after every load. It can't open `chrome://` pages.

Screenshot every visual check and attach it to the ticket. Save it to a file rather than into the conversation, so you can attach it:

    take_screenshot with filePath /tmp/ralph-shots/<what>.png   (fullPage: true for the whole page, uid for one element)
    $RALPH/discord.sh attach <post id> /tmp/ralph-shots/<what>.png "what the shot shows"

If the server isn't connected, `$RALPH/browser.sh` starts the browser and the `chrome-devtools` CLI has the same tools: `chrome-devtools start --browserUrl http://127.0.0.1:9222 --workspace=/`, then e.g. `chrome-devtools take_screenshot <page id> --filePath <file>`. Don't spend the session retrying the server.

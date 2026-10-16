# RALPH LOOP

You are one iteration of an AFK loop. Recent commits and every open ticket are above. Each ticket is a post in this project's Discord forum, identified by its post id; its tag is its state. Change tags only with the ticket tool above.

# TASK SELECTION

Only tickets tagged `Ready` are yours. If one depends on a ticket that is not `Resolved`, tag it `Blocked`, replying with the blocker's post id, and skip it. Never touch tickets tagged `Blocked`, `Needs Info`, `Claimed` or `Resolved` except as below.

If no ticket qualifies, output <promise>NO MORE TASKS</promise> and stop.

Otherwise pick one, in this priority order (oldest post first as a tiebreak):

1. Critical bugfixes
2. Development infrastructure (tests, types, dev scripts): precursors to features
3. Tracer bullets: a tiny end-to-end slice of a feature through every layer, expanded later
4. Polish and quick wins
5. Refactors

Tag it `Claimed` before any other work.

# IMPLEMENTATION

Explore what the ticket touches, use `/tdd` where there is a testable seam, run the checks the repo has, then `/code-review` your diff and apply what it finds.

# CLOSING THE TICKET

Commit any code changes as one commit, message referencing the post id. Then reply in the post with a short note for the human (what changed, or what you need) and set its tag to one of:

- `Resolved`: the ticket's acceptance criteria are met.
- `Needs Info`: blocked on a decision or hands only the human has. The reply is the question.

If you resolved it, re-tag `Ready` any `Blocked` ticket that was waiting only on this one.

# FINAL RULES

ONLY WORK ON A SINGLE TICKET. Stop after closing it.

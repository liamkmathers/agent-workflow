#!/bin/bash
# PreToolUse on Bash. Exit 2 blocks the command and shows stderr to Claude.
# Server-side branch protection is the real gate. This saves the agent a wasted turn.
CMD=$(jq -r '.tool_input.command // ""')
if echo "$CMD" | grep -Eq 'git\s+push\b.*\b(main|master)\b' \
   || echo "$CMD" | grep -Eq 'gh\s+pr\s+merge' \
   || echo "$CMD" | grep -Eq 'gh\s+pr\s+review\b.*--approve'; then
  echo "Blocked: agents never push to main, merge, or approve PRs. Open a PR with /pr and stop." >&2
  exit 2
fi
exit 0

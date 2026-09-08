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
# Fix tasks: shell writes into test paths are refused too (the Edit hook only sees Edit/Write tools).
. "$(dirname "$0")/lib.sh"
if [ "$(task_kind)" = "fix" ]; then
  RX=$(grep -m1 '^test_regex:' "$(root)/.agent-workflow" 2>/dev/null | cut -d' ' -f2-); : "${RX:=(\\.test\\.|\\.spec\\.|__tests__/)}"
  if echo "$CMD" | grep -Eq "(>|>>|tee|sed -i|mv |cp |rm |python|node|perl).*" && echo "$CMD" | grep -Eq "$RX"; then
    echo "Blocked: fix task; test files are frozen and this command references a test path. Fix the code, not the test. Use the Edit tool for repo files." >&2
    exit 2
  fi
fi
exit 0

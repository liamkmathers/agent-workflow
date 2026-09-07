#!/bin/bash
# PreToolUse on Edit|Write|MultiEdit.
# If the current branch's task file says kind: fix, block any edit to a test file.
# The failing test was committed before the fix started; the agent must not change it.
FILE=$(jq -r '.tool_input.file_path // ""')
BR=$(git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null)
ID="${BR#task/}"
TASK="${CLAUDE_PROJECT_DIR:-.}/tasks/${ID}.md"
[ -f "$TASK" ] || exit 0
KIND=$(grep -m1 '^kind:' "$TASK" | awk '{print $2}')
RX=$(grep -m1 '^test_regex:' "${CLAUDE_PROJECT_DIR:-.}/.agent-workflow" 2>/dev/null | cut -d' ' -f2-)
: "${RX:=(\.test\.|\.spec\.|__tests__/)}"
if [ "$KIND" = "fix" ] && echo "$FILE" | grep -Eq "$RX"; then
  echo "Blocked: this is a fix task (tasks/${ID}.md). Test files are frozen. Fix the code, not the test." >&2
  exit 2
fi
exit 0

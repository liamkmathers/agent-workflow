#!/bin/bash
# Stop hook. Deterministic completion gate. Acts only when the agent says TASK COMPLETE on a task branch.
# Exit 2 + stderr = Claude keeps working and sees the reason. stop_hook_active prevents a loop.
. "$(dirname "$0")/lib.sh"
INPUT=$(cat)
[ "$(echo "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0
ID=$(task_id); [ -n "$ID" ] || exit 0
TASK=$(task_file); [ -f "$TASK" ] || exit 0
ROOT=$(root)
T=$(echo "$INPUT" | jq -r '.transcript_path // ""')
LAST=$(last_texts "$T" 40)
echo "$LAST" | grep -Eq "^TASK COMPLETE\s*$" || exit 0

FAIL=""
TESTCMD=$(grep -m1 '^test:' "$ROOT/.agent-workflow" 2>/dev/null | cut -d: -f2- | xargs)
TYPECMD=$(grep -m1 '^typecheck:' "$ROOT/.agent-workflow" 2>/dev/null | cut -d: -f2- | xargs)
: "${TESTCMD:=npm test}"; : "${TYPECMD:=npx tsc --noEmit}"
(cd "$ROOT" && eval "$TESTCMD" >/tmp/stop-gate-test.log 2>&1) || FAIL="$FAIL\n- tests failed ($TESTCMD). See /tmp/stop-gate-test.log."
(cd "$ROOT" && eval "$TYPECMD" >/tmp/stop-gate-tsc.log 2>&1) || FAIL="$FAIL\n- typecheck failed ($TYPECMD). See /tmp/stop-gate-tsc.log."
[ -f "$ROOT/tasks/$ID.plan.md" ] || FAIL="$FAIL\n- tasks/$ID.plan.md is missing."
[ -f "$ROOT/tasks/$ID.verify.md" ] || FAIL="$FAIL\n- tasks/$ID.verify.md is missing. Invoke the verifier subagent first."
grep -q '^Verdict: READY\|^READY' "$ROOT/tasks/$ID.verify.md" 2>/dev/null || FAIL="$FAIL\n- verifier verdict is not READY."
UNTICKED=$(grep -c '^- \[ \]' "$TASK")
if [ "$UNTICKED" -gt 0 ] && ! echo "$LAST" | grep -qi "not done"; then
  FAIL="$FAIL\n- $UNTICKED acceptance criteria unticked in tasks/$ID.md and no 'Not done' section in your message."
fi
if [ -f "$ROOT/scripts/wiki-lint.sh" ]; then
  (cd "$ROOT" && bash scripts/wiki-lint.sh >/tmp/stop-gate-wiki.log 2>&1) || FAIL="$FAIL\n- wiki lint failed. See /tmp/stop-gate-wiki.log."
fi
if [ -n "$FAIL" ]; then
  printf "Completion gate failed for %s:%b\nResolve these, then say TASK COMPLETE again.\n" "$ID" "$FAIL" >&2
  exit 2
fi
exit 0

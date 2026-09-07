#!/bin/bash
# PostToolUse on edits. If a task file changed, regenerate tasks/INDEX.md from frontmatter.
. "$(dirname "$0")/lib.sh"
FILE=$(jq -r '.tool_input.file_path // ""')
case "$FILE" in */tasks/T-*.md) ;; *) exit 0 ;; esac
ROOT=$(root); [ -d "$ROOT/tasks" ] || exit 0
{
  echo "# Tasks"; echo; echo "| ID | Status | Kind | Title | Source |"; echo "|---|---|---|---|---|"
  for f in "$ROOT"/tasks/T-*.md; do
    case "$f" in *.plan.md|*.verify.md|*.log.md) continue;; esac
    id=$(grep -m1 '^id:' "$f" | awk '{print $2}'); st=$(grep -m1 '^status:' "$f" | awk '{print $2}')
    k=$(grep -m1 '^kind:' "$f" | awk '{print $2}'); src=$(grep -m1 '^source:' "$f" | cut -d' ' -f2-)
    t=$(grep -m1 '^# ' "$f" | sed 's/^# [^:]*: //')
    echo "| [$id]($(basename "$f")) | $st | $k | $t | $src |"
  done
} > "$ROOT/tasks/INDEX.md"
exit 0

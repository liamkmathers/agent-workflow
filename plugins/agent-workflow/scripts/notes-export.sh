#!/bin/bash
# Called by /pr once. Writes tasks/<ID>.log.md from this branch's NOTE: events in ~/.claude/status, regenerates tasks/INDEX.md.
. "$(dirname "$0")/lib.sh"
ID="${1:-$(task_id)}"; [ -n "$ID" ] || { echo "no task id" >&2; exit 1; }
ROOT=$(root); DIR="$HOME/.claude/status"
{
  echo "# Working notes: $ID"; echo
  cat "$DIR"/*.jsonl 2>/dev/null | jq -r --arg t "$ID" 'select(.event=="note" and .task==$t) | "- \(.ts) \(if .agent != "" then "[\(.agent)] " else "" end)\(.detail)"'
} > "$ROOT/tasks/$ID.log.md"
echo '{"tool_input":{"file_path":"'"$ROOT/tasks/$ID.md"'"}}' | bash "$(dirname "$0")/task-index.sh"
echo "wrote tasks/$ID.log.md and tasks/INDEX.md"

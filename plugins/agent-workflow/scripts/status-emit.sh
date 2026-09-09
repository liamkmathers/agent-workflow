#!/bin/bash
# Writes one JSON line per lifecycle event to ~/.claude/status/<session>.jsonl.
# Also: extracts lines starting with NOTE: from the transcript into note events (exported to tasks/<ID>.log.md by /pr),
# reads plan.md step markers into a steps array, tags subagent events.
. "$(dirname "$0")/lib.sh"
INPUT=$(cat)
DIR="$HOME/.claude/status"; mkdir -p "$DIR"
SID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')
AGENT=$(echo "$INPUT" | jq -r '.agent_id // .agent_type // ""')       # non-empty when inside a subagent
ROOT=$(root); BR=$(branch); ID=$(task_id)
TITLE=""; [ -n "$ID" ] && [ -f "$ROOT/tasks/$ID.md" ] && TITLE=$(grep -m1 '^# ' "$ROOT/tasks/$ID.md" | sed 's/^# //')
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
OUT="$DIR/$SID.jsonl"

emit() { # $1 event $2 state $3 detail $4 agent $5 extra-json
  jq -cn --arg ts "$TS" --arg sid "$SID" --arg ev "$1" --arg st "$2" --arg tool "$TOOL" --arg br "$BR" \
         --arg task "$ID" --arg title "$TITLE" --arg detail "$3" --arg root "$ROOT" --arg agent "$4" --argjson extra "${5:-{\}}" \
    '{ts:$ts,session:$sid,event:$ev,state:$st,tool:$tool,branch:$br,task:$task,title:$title,detail:$detail,root:$root,agent:$agent} + $extra' >> "$OUT"
}

# Steps from plan.md: "- [ ]" pending, "- [~]" current, "- [x]" done under "## Order of work".
STEPS='[]'
if [ -n "$ID" ] && [ -f "$ROOT/tasks/$ID.plan.md" ]; then
  STEPS=$(awk '/^## Order of work/{f=1;next} /^## /{f=0} f && /^[0-9]+\. |^- \[/' "$ROOT/tasks/$ID.plan.md" \
    | jq -R -s 'split("\n") | map(select(length>0)) | map(
        if test("\\[x\\]") then {state:"done"} elif test("\\[~\\]") then {state:"current"} else {state:"pending"} end
        + {text: (sub("^[0-9]+\\. ";"") | sub("^- ";"") | sub("^\\[[ x~]\\] ";""))})' 2>/dev/null || echo '[]')
fi

case "$EVENT" in
  SessionStart) emit start working "" "" "{\"steps\":$STEPS}" ;;
  PreToolUse)   # only wired for Task|Agent: a subagent is being spawned
    SUB=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // .tool_input.agent // ""')
    DESC=$(echo "$INPUT" | jq -r '.tool_input.description // ""' | cut -c1-160)
    emit spawn working "$DESC" "$SUB" ;;
  PostToolUse)
    DETAIL=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.command // .tool_input.description // ""' | cut -c1-160)
    emit tool working "$DETAIL" "$AGENT" "{\"steps\":$STEPS}"
    # Built-in task list tool: surface its items as steps too.
    case "$TOOL" in TodoWrite|TaskCreate|TaskUpdate)
      TODO=$(echo "$INPUT" | jq -c '[.tool_input.todos[]? | {text:.content, state:(if .status=="in_progress" then "current" elif .status=="completed" then "done" else "pending" end)}]' 2>/dev/null)
      [ -n "$TODO" ] && [ "$TODO" != "[]" ] && emit steps working "" "$AGENT" "{\"steps\":$TODO}" ;;
    esac
    # NOTE: lines since last check.
    T=$(echo "$INPUT" | jq -r '.transcript_path // .agent_transcript_path // ""')
    if [ -n "$T" ] && [ -f "$T" ]; then
      OFF="$DIR/$SID${AGENT:+.$AGENT}.offset"; PREV=$(cat "$OFF" 2>/dev/null || echo 0); NOW=$(wc -l < "$T")
      if [ "$NOW" -gt "$PREV" ]; then
        tail -n +"$((PREV+1))" "$T" | jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text' 2>/dev/null \
          | grep -E '^NOTE:' | cut -c1-240 | while IFS= read -r N; do
            emit note working "$N" "$AGENT"
          done
        echo "$NOW" > "$OFF"
      fi
    fi ;;
  Notification) emit waiting waiting "$(echo "$INPUT" | jq -r '.message // ""' | cut -c1-160)" "$AGENT" ;;
  SubagentStop)
    T=$(echo "$INPUT" | jq -r '.agent_transcript_path // ""'); LAST=$(last_texts "$T" 1 | cut -c1-160)
    emit subagent_stop working "$LAST" "$AGENT" ;;
  Stop)
    T=$(echo "$INPUT" | jq -r '.transcript_path // ""'); LAST=$(last_texts "$T" 1 | cut -c1-160)
    ST=idle; last_texts "$T" 40 | grep -Eq "^TASK COMPLETE\s*$" && ST=completed
    emit stop "$ST" "$LAST" "" "{\"steps\":$STEPS}" ;;
  *) emit "$EVENT" working "" "$AGENT" ;;
esac
exit 0

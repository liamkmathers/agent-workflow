#!/bin/bash
# Shared helpers for hook scripts. Source this; do not run it.
root() { echo "${CLAUDE_PROJECT_DIR:-$(pwd)}"; }
branch() { git -C "$(root)" rev-parse --abbrev-ref HEAD 2>/dev/null || echo ""; }
task_id() { local b; b=$(branch); case "$b" in task/*) echo "${b#task/}";; *) echo "";; esac; }
task_file() { local id; id=$(task_id); [ -n "$id" ] && echo "$(root)/tasks/$id.md"; }
task_kind() { local f; f=$(task_file); [ -f "$f" ] && grep -m1 '^kind:' "$f" | awk '{print $2}'; }
# Last N assistant text blocks from a transcript JSONL.
last_texts() { tail -n 400 "$1" 2>/dev/null | jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text' 2>/dev/null | tail -n "${2:-1}"; }

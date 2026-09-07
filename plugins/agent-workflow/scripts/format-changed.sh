#!/bin/bash
# PostToolUse on edits. Formats only the file that changed. Fast, scoped, silent.
FILE=$(jq -r '.tool_input.file_path // ""')
case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.css|*.json|*.md)
    npx --no-install prettier --write "$FILE" >/dev/null 2>&1 || true ;;
esac
exit 0

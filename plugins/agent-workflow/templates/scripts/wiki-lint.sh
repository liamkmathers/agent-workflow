#!/bin/bash
# Deterministic wiki checks. No LLM. Run in CI and by the stop gate.
# 1. Every page under docs/wiki has frontmatter with title and summary.
# 2. Every [[link]] resolves to a page.
# 3. Regenerates docs/wiki/INDEX.md from frontmatter.
set -e
W="docs/wiki"; [ -d "$W" ] || exit 0
FAIL=0
for f in "$W"/*.md; do
  case "$(basename "$f")" in INDEX.md|README.md|_*) continue;; esac
  head -1 "$f" | grep -q '^---$' || { echo "$f: missing frontmatter"; FAIL=1; }
  grep -q '^title:' "$f" || { echo "$f: missing title:"; FAIL=1; }
  grep -q '^summary:' "$f" || { echo "$f: missing summary:"; FAIL=1; }
  grep -o '\[\[[^]]*\]\]' "$f" | tr -d '[]' | sort -u | while read -r L; do
    [ -f "$W/$L.md" ] || { echo "$f: broken link [[${L}]]"; exit 3; }
  done || FAIL=1
done
{
  echo "# Wiki index"; echo
  for f in "$W"/*.md; do
    case "$(basename "$f")" in INDEX.md|README.md|_*) continue;; esac
    n=$(basename "$f" .md); t=$(grep -m1 '^title:' "$f" | cut -d' ' -f2-); s=$(grep -m1 '^summary:' "$f" | cut -d' ' -f2-)
    echo "- [[$n]] $t: $s"
  done
} > "$W/INDEX.md"
exit $FAIL

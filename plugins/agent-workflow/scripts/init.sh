#!/bin/bash
# Scaffold per-repo files from plugin templates. Never overwrites. Fills placeholders from detection.
set -u
T="$(cd "$(dirname "$0")/../templates" && pwd)"
R="${CLAUDE_PROJECT_DIR:-$(pwd)}"; cd "$R"

# Detect
if [ -f pnpm-lock.yaml ]; then PM=pnpm; INSTALL="pnpm install --frozen-lockfile"; RUN="pnpm"
elif [ -f bun.lockb ] || [ -f bun.lock ]; then PM=bun; INSTALL="bun install --frozen-lockfile"; RUN="bun run"
elif [ -f yarn.lock ]; then PM=yarn; INSTALL="yarn install --frozen-lockfile"; RUN="yarn"
else PM=npm; INSTALL="npm ci"; RUN="npm run"; fi
has() { if command -v jq >/dev/null; then jq -e --arg s "$1" '.scripts[$s]' package.json >/dev/null 2>&1; else grep -Eq "\"$1\"[[:space:]]*:" package.json; fi; }
TEST="__TEST__"; has test && TEST="$RUN test"
LINT="__LINT__"; has lint && LINT="$RUN lint"
TYPE="npx tsc --noEmit"; has typecheck && TYPE="$RUN typecheck"
if grep -q '"next"' package.json 2>/dev/null && ! has typecheck; then TYPE="npx next typegen && npx tsc --noEmit"; fi
if find . -path ./node_modules -prune -o -type d -name tests -print -o -type d -name __tests__ -print 2>/dev/null | grep -q .; then
  TEST_REGEX='(\.test\.|\.spec\.|__tests__/|^tests/)'; else TEST_REGEX='(\.test\.|\.spec\.)'; fi
SRC=$(for d in app src lib components pages server; do [ -d "$d" ] && printf "%s " "$d"; done); SRC="${SRC% }"; : "${SRC:=src}"

esc() { printf '%s' "$1" | sed 's/[\\&#]/\\&/g'; }
fill() { sed -e "s#__PM__#$PM#g" -e "s#__INSTALL__#$INSTALL#g" -e "s#__TEST__#$TEST#g" -e "s#__LINT__#$LINT#g" \
             -e "s#__TYPECHECK__#$TYPE#g" -e "s#__TEST_REGEX__#$(esc "$TEST_REGEX")#g" -e "s#__SRC_DIRS__#$SRC#g" "$1"; }
put() { # src dest
  if [ -e "$2" ]; then echo "skip   $2 (exists)"; else mkdir -p "$(dirname "$2")"; fill "$1" > "$2"; echo "create $2"; fi; }

put "$T/agent-workflow.conf" .agent-workflow
put "$T/tasks/TEMPLATE.md" tasks/TEMPLATE.md
put "$T/tasks/PLAN_TEMPLATE.md" tasks/PLAN_TEMPLATE.md
put "$T/github/pull_request_template.md" .github/pull_request_template.md
put "$T/github/pr.yml" .github/workflows/pr.yml
put "$T/REVIEW.md" REVIEW.md
put "$T/dependency-cruiser.cjs" .dependency-cruiser.cjs
put "$T/scripts/wiki-lint.sh" scripts/wiki-lint.sh; chmod +x scripts/wiki-lint.sh
put "$T/wiki/README.md" docs/wiki/README.md
put "$T/wiki/module.md" docs/wiki/_module.md
put "$T/wiki/decision.md" docs/wiki/_decision.md
put "$T/rules/ui.md" .claude/rules/ui.md
put "$T/scripts/pre-push" scripts/hooks/pre-push; chmod +x scripts/hooks/pre-push
git config core.hooksPath scripts/hooks && echo "set    core.hooksPath=scripts/hooks (local pre-push refuses pushes to main)"
mkdir -p docs/assessments/img
if [ -f CLAUDE.md ] && grep -q '^## Workflow' CLAUDE.md; then echo "skip   CLAUDE.md workflow section (exists)"
else cat "$T/CLAUDE.workflow.md" >> CLAUDE.md; echo "append CLAUDE.md workflow section"; fi
echo
echo "Detected: pm=$PM test='$TEST' lint='$LINT' typecheck='$TYPE' test_regex='$TEST_REGEX' src='$SRC'"
grep -l '__[A-Z_]*__' .agent-workflow .github/workflows/pr.yml .dependency-cruiser.cjs 2>/dev/null | sed 's/^/placeholder remaining in: /'

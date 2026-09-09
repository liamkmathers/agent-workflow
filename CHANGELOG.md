# 0.1.2 (2026-09-08), from the first aw-test run
- /pr: agent may invoke it (disable-model-invocation removed). It was contradicting the workflow.
- NOTE hook: matches only lines starting with NOTE:; no longer writes tasks/<ID>.log.md mid-session (was causing "hook log churn" commits). /pr exports notes once via scripts/notes-export.sh, which also regenerates tasks/INDEX.md.
- init.sh: Next.js repos get typecheck "npx next typegen && npx tsc --noEmit" (LayoutProps is generated).
- Bash hook: on fix tasks, refuses shell commands that write into test paths. Workflow rule: repo edits via Write/Edit tools only.
- tasks: kind "chore" for config/CI/docs tasks (no test-first).
- Workflow: honest-exit rule (wrong frozen test or wrong plan: stop, NOTE:, Not done, wait).
- REVIEW.md: monthly pruning section. README: outcome vs process gate table.
- init.sh: installs scripts/hooks/pre-push and sets core.hooksPath (fallback for private repos on GitHub Free, where rulesets are not enforced).

# 0.1.3 (2026-09-09), from the T-002 run
- Stop gate and status feed match only a line that is exactly TASK COMPLETE (was matching mentions of the phrase).
- Verifier reads test/typecheck commands from .agent-workflow (was hardcoding npx tsc --noEmit).
- Verifier: CI=1 and timeout 180 on every command, no servers, install first if node_modules is missing. Two verifier stalls at the 600s watchdog on fresh worktrees.
- /pr and workflow: the completion phrase is written only as the final line of a real completion.

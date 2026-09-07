
## Workflow (every task)
1. Read `tasks/<ID>.md` before touching code. If no task file exists for what you were asked, draft one from `tasks/TEMPLATE.md`, show it, and stop for confirmation.
2. Start in plan mode. Write `tasks/<ID>.plan.md` from `tasks/PLAN_TEMPLATE.md`. Wait for approval before editing code.
3. Work on branch `task/<ID>` in its own worktree. Commit in small steps.
4. Keep the plan current: mark the step you are on `[~]`, done steps `[x]`. If the diff departs from the plan, update the plan in the same commit.
5. When you notice a discrepancy, a surprise, or a decision mid-task, write one line starting with `NOTE:`. Hooks collect these into `tasks/<ID>.log.md`.
6. `kind: fix` tasks: write the failing test first, run it, confirm it fails for the expected reason, commit it. Then fix the code. Test files are frozen after that commit (a hook enforces this).
7. `kind: feature` tasks: invoke `test-writer` with the task ID and the interface before implementing.
8. If the change makes a page in `docs/wiki/` false, fix that page in the same commit. New "why" decisions go through `/decide`.
9. When done, invoke `verifier` with the task ID. Then run `/pr`. Then stop.
10. Never push to main. Never merge. Never approve a PR. Never edit `tasks/<ID>.verify.md` by hand.

## Things Claude gets wrong
(Added by `/lesson` when a mistake repeats. One line each, with task IDs.)

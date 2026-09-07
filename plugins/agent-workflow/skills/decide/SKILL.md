---
name: decide
description: Record an architectural or product decision as a wiki page with context, alternatives, and consequences. Use when a "why" choice is made that future agents should not relitigate.
---
# Decide

1. Create `docs/wiki/decision-<slug>.md` from `docs/wiki/_decision.md`. Date today. `task:` the current task ID if on a task branch.
2. Fill Context, Decision, Rejected (one line per alternative, why not), Consequences. Keep it under 40 lines.
3. Link it from the module page it affects: add `[[decision-<slug>]]` under that page's Decisions section.
4. Run `bash scripts/wiki-lint.sh`. Fix anything it reports.
5. Commit with the current work. Final message: the page path and the one-line summary.

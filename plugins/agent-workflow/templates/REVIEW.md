# Review instructions

Every PR gets three passes, each from a separate subagent with its own context:
- **Bugs** (`review-bugs`): logic errors, broken edge cases, regressions.
- **Security** (`review-security`): injection, auth and RLS gaps, secrets, PII in logs.
- **Compliance** (`review-compliance`): the diff matches `tasks/<ID>.md`, `tasks/<ID>.plan.md`, and `docs/NORTH_STAR.md`.

## Important vs Nit
Important: would break behavior, leak data, breach a policy, or leave an acceptance criterion unmet.
Nit: style, naming, ordering, comments.

## Caps
At most five nits per pass. Summarize the rest as a count.

## Do not report
Generated files. Anything `npm run lint` or `tsc` already enforces. Formatting (a hook runs prettier).

## Shadow mode
Until 2026-10-06, review findings are comments only. No finding blocks a merge. Liam rates findings; after one month, Important findings from passes with under 20% false positives become required checks.

## Feedback loop
A finding that appears for the second time across PRs becomes a line in CLAUDE.md under "Things Claude gets wrong", added in the same PR that found it. Use `/lesson`.

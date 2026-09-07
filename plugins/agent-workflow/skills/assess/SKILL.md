---
name: assess
description: Run an analysis or comparison and write it as a committed assessment with findings, candidate tasks, exclusions, and open questions. Use when asked to analyze, compare, audit, or assess anything about the product, codebase, or a competitor.
disable-model-invocation: true
---
# Assessment

You are producing an artifact, not a chat answer. The output is a file at `docs/assessments/<YYYY-MM-DD>-<slug>.md`, committed on a branch `assess/<slug>`.

## Evidence rules
- Every finding names its evidence: a file path and line, a measured number with the command that produced it, a rendered page, a screenshot.
- Screenshots go in `docs/assessments/img/<slug>-<n>.png`, not in the scratchpad.
- No finding rests on the marketing copy of the thing being assessed. Render it, read its source, measure it.

## File shape (exact headings)

```
# Assessment: <title>
Date: <date>. Prompt: "<the prompt you were given, verbatim>".
Evidence: <list of paths and commands>.

## Findings
One line per finding, with its evidence in the same line.

## Candidate tasks
One block per recommendation, ordered by return on effort.
### C<n>: <imperative title>
Acceptance: <checkable outcomes, semicolon-separated>
Files: <paths expected to change>
Effort: <hours or days>
Why: <one line>

## Do not do
Things considered and rejected, each with the reason (cite docs/NORTH_STAR.md where it applies).

## Open questions
Decisions only Liam can make. One line each.
```

## After writing
1. `git checkout -b assess/<slug>`, commit the file and images, `gh pr create --fill --label assessment`.
2. Final message: the path of the file, the count of candidate tasks, and the open questions verbatim. Nothing else. Do not create task files; Liam runs `/accept <path> C1 C3` for the ones he wants.

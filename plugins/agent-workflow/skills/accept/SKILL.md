---
name: accept
description: Turn accepted candidates from an assessment into task files. Usage: /accept <assessment path> C1 C3. Creates tasks/T-<n>.md for each, numbered after the highest existing ID.
disable-model-invocation: true
---
# Accept

1. Read the assessment file given. Find each `### C<n>` block named in the arguments.
2. Next ID: highest `T-<n>` under `tasks/` plus one.
3. For each candidate, create `tasks/T-<n>.md` from `tasks/TEMPLATE.md`. `kind` from the candidate's nature (feature unless it fixes a defect). `status: accepted`. `source:` the assessment path with `#C<n>`. Acceptance criteria: split the candidate's Acceptance line on semicolons, one box each, plus "Existing tests pass". Files expected to change: the candidate's Files line. Out of scope: anything the assessment's "Do not do" section forbids that is adjacent.
4. Regenerate `tasks/INDEX.md` (a hook does this on write; confirm it exists).
5. Commit on a branch `tasks/accept-<date>` and open a PR, or commit directly if Liam says so.
6. Final message: the IDs created, one line each with title. Nothing else.

---
name: pr
description: Open the pull request for the current task branch in the required shape, then stop. Use when implementation of a task is finished and verified.
disable-model-invocation: true
---
# Open PR

Preconditions. Check each; do not assume.
1. Branch is `task/<ID>` and `tasks/<ID>.md` exists.
2. `tasks/<ID>.plan.md` exists, every step is `[x]`, and it matches the diff. If implementation departed from the plan, update the plan now.
3. `tasks/<ID>.verify.md` exists with verdict READY. If not, invoke the `verifier` subagent with the task ID and wait.
4. Tests, typecheck, `bash scripts/wiki-lint.sh`, and `npx depcruise --config .dependency-cruiser.cjs <src dirs>` pass. Commands are in `.agent-workflow`.

Then:
1. Tick every acceptance box in `tasks/<ID>.md` the verifier marked PASS. Leave FAIL and CANNOT CHECK unticked.
2. Set `status: pr-open` in the task file frontmatter. Commit, including `tasks/<ID>.log.md` if present.
3. Push the branch. `gh pr create` using `.github/pull_request_template.md`: every criterion with its box state; Not done lists every unticked criterion and every file outside the expected list; the verifier report pasted in full; the log file linked under "Working notes".
4. Invoke `review-bugs`, `review-security`, `review-compliance` with the task ID. Post each final message as a PR comment with `gh pr comment`.
5. Say `TASK COMPLETE` followed by the PR URL. Stop. Do not merge. Do not approve. Do not address findings unless asked.

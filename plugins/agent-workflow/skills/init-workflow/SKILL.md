---
name: init-workflow
description: Scaffold the agent-workflow files into the current repo (task templates, PR template, CI, REVIEW.md, wiki, import rules, CLAUDE.md sections). Run once per repo after installing the plugin.
disable-model-invocation: true
---
# Init workflow

1. Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/init.sh"`. It detects the package manager from the lockfile, reads script names from `package.json`, detects the test layout, and copies every template with placeholders filled. It never overwrites an existing file; it reports skips.
2. Read its output. For anything it could not detect it writes `__PLACEHOLDER__`; ask Liam for the value and replace it in `.agent-workflow`, `.github/workflows/pr.yml`, and `.dependency-cruiser.cjs`.
3. Append `CLAUDE.workflow.md` content to `CLAUDE.md` if the Workflow section is not already there. If `CLAUDE.md` does not exist, create it with a Commands section (from `.agent-workflow`), a Layout section (top-level directories, one line each), then the workflow content.
4. `npm i -D dependency-cruiser prettier` (or the pnpm/bun equivalent). Run `npx depcruise --config .dependency-cruiser.cjs <src dirs>` once. Report violations; do not fix them. Liam decides whether to adjust rules or code.
5. Run `bash scripts/wiki-lint.sh`.
6. Print these manual steps for Liam and stop:
   - GitHub → Settings → Rules → new ruleset on `main`: require PR with 1 approval, require status check `pr-checks`, block force push, no bypass.
   - Commit and push this scaffold to `main` once (the last direct push) so `pr-checks` exists, then select it in the ruleset.
   - `brew install jq gh` if missing.

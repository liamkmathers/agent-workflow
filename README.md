# agent-workflow

Written intent in, gated PR out. A Claude Code plugin plus a per-repo scaffold.

## Install (once)
```
/plugin marketplace add <your-github-user>/agent-workflow
/plugin install agent-workflow@liam-plugins
```
Requires `jq` and `gh` (`brew install jq gh`).

## Per repo
```
/init-workflow
```
Then set branch protection on `main` by hand (the skill prints the exact settings), commit the scaffold to `main` once, and select `pr-checks` as the required check.

## What the plugin carries
- Skills: `/assess`, `/accept`, `/pr`, `/lesson`, `/decide`, `/init-workflow`
- Agents: `verifier`, `test-writer`, `review-bugs`, `review-security`, `review-compliance`
- Hooks: push block, test freeze on fix tasks, formatter, completion gate, task index, status feed

## What `/init-workflow` writes into the repo
`.agent-workflow`, `tasks/TEMPLATE.md`, `tasks/PLAN_TEMPLATE.md`, `.github/pull_request_template.md`, `.github/workflows/pr.yml`, `REVIEW.md`, `.dependency-cruiser.cjs`, `scripts/wiki-lint.sh`, `docs/wiki/`, `.claude/rules/ui.md`, and a Workflow section in `CLAUDE.md`.

## The loop
```
/assess ─► docs/assessments/<date>-<slug>.md
   │  Liam reads, answers open questions
/accept <path> C1 C3 ─► tasks/T-<n>.md
   │  per task, in its own worktree:
   plan mode ─► tasks/T-<n>.plan.md  (Liam approves)
   implement  (fix: failing test first, tests frozen; feature: test-writer first)
   verifier  ─► tasks/T-<n>.verify.md
   /pr       ─► PR + three review comments
   TASK COMPLETE  (stop gate checks tests, typecheck, plan, verify, criteria, wiki)
Liam: file list vs expected ─► compliance comment ─► diff ─► approve
/lesson on the second occurrence of any mistake
```

## Gates: outcome vs process
Outcome gates state facts about the code and stay permanent. Process gates encode today's failure modes; review them monthly (see REVIEW.md) and remove any that has not caught anything in two months.

| Gate | Kind |
|---|---|
| Branch ruleset / local pre-push | outcome |
| CI: tests, typecheck, lint, import rules | outcome |
| Push, merge, approve block (Claude hook) | outcome |
| Test freeze on fix tasks | outcome |
| Mandatory plan mode before code | process |
| Plan step markers `[~]` `[x]` | process |
| `TASK COMPLETE` marker and stop gate | process |
| Verify file required | process |
| Three review passes | process (shadow mode first) |

## Layout
```
.claude-plugin/marketplace.json
plugins/agent-workflow/     the plugin
menubar/                    AgentBar.swift, separate Xcode project
```

---
name: lesson
description: Record a mistake Claude has now made twice so it does not recur. Picks the right home: a CLAUDE.md line, a path-scoped rule, a skill, or a hook. Use when a review finding or correction repeats.
---
# Lesson

Ask what shape the mistake has, then write to the matching place. Never more than one.

| Shape | Home |
|---|---|
| Wrong single choice, applies everywhere | One line under `## Things Claude gets wrong` in `CLAUDE.md` |
| Wrong single choice, applies to some paths | `.claude/rules/<slug>.md` with `paths:` frontmatter |
| Botched procedure of three or more steps | `.claude/skills/<slug>/SKILL.md` with the steps in order |
| Must never happen, no exceptions | A `PreToolUse` hook in `.claude/settings.json`; write the script under `.claude/hooks/` |

Line shape: what not to do, what to do instead, where it happened. Under 140 characters. Example:
`- Do not use native <select>; use components/ui/Menu. (T-051, T-054)`

Skill shape: `name`, `description` naming the trigger, then numbered steps, then a one-line check that proves it was done right. Cite the task IDs at the bottom.

Commit in the same branch as the fix. These files are reviewed like code. Say which home you chose and why in one sentence.

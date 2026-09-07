# AgentBar

Menu bar view of running Claude Code sessions. Separate Xcode project; not part of the plugin.

Data source: `~/.claude/status/<session>.jsonl`, one JSON line per hook event, written by the plugin's `status-emit.sh`.

Events: `start`, `tool`, `spawn`, `subagent_stop`, `note`, `steps`, `waiting`, `stop`. Fields: `ts, session, event, state, tool, branch, task, title, detail, root, agent, steps[]`.

Display per session: glyph and state, task ID and title, elapsed time. Submenu: current tool, plan steps with the current one bold, subagents (running: current tool; done: last line), last eight `NOTE:` lines, open worktree.

Header: `◐<waiting> ●<working>`. macOS notification when a session flips to waiting.

Build: Xcode, macOS App, SwiftUI, deployment target 13.0. Replace the generated App file with `AgentBar.swift`. Info.plist `LSUIElement = YES`. Capability: User Notifications.

Not in scope: sending instructions to sessions. Use `claude agents` for that.

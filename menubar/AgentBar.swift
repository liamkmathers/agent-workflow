// AgentBar: macOS menu bar view of Claude Code sessions.
// Reads ~/.claude/status/*.jsonl written by the agent-workflow plugin's status-emit.sh.
// Xcode: macOS App, SwiftUI, target 13.0. Replace the App file with this. Info.plist: LSUIElement = YES.
// Add the "User Notifications" capability. Sign to Run Locally is enough.

import SwiftUI
import UserNotifications

struct Step: Decodable, Hashable { let text: String; let state: String }

struct Event: Decodable {
    let ts: String, session: String, event: String, state: String
    let tool: String, branch: String, task: String, title: String, detail: String, root: String
    let agent: String?
    let steps: [Step]?
}

struct Subagent: Identifiable { let id: String; var lastTool: String; var lastLine: String; var done: Bool }

struct Session: Identifiable {
    let id: String
    var state = "working", task = "", title = "", branch = "", root = "", lastLine = "", lastTool = ""
    var startedAt: Date?, updatedAt: Date?
    var steps: [Step] = []
    var notes: [String] = []
    var subagents: [String: Subagent] = [:]
    var label: String { task.isEmpty ? (branch.isEmpty ? String(id.prefix(8)) : branch) : task }
}

@MainActor
final class StatusStore: ObservableObject {
    @Published var sessions: [Session] = []
    private var source: DispatchSourceFileSystemObject?
    private var notified: Set<String> = []
    private let dir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude/status")
    private let iso = ISO8601DateFormatter()

    init() {
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        reload(); watch()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in Task { @MainActor in self.reload() } }
    }

    private func watch() {
        let fd = open(dir.path, O_EVTONLY); guard fd >= 0 else { return }
        let s = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: [.write, .extend, .attrib], queue: .main)
        s.setEventHandler { [weak self] in self?.reload() }
        s.setCancelHandler { close(fd) }
        s.resume(); source = s
    }

    func reload() {
        let dec = JSONDecoder()
        var out: [Session] = []
        let files = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        for f in files where f.pathExtension == "jsonl" {
            guard let text = try? String(contentsOf: f, encoding: .utf8) else { continue }
            var s = Session(id: f.deletingPathExtension().lastPathComponent)
            for line in text.split(separator: "\n") {
                guard let e = try? dec.decode(Event.self, from: Data(line.utf8)) else { continue }
                let t = iso.date(from: e.ts)
                if s.startedAt == nil { s.startedAt = t }
                s.updatedAt = t
                if !e.task.isEmpty { s.task = e.task; s.title = e.title }
                if !e.branch.isEmpty { s.branch = e.branch }
                if !e.root.isEmpty { s.root = e.root }
                if let st = e.steps, !st.isEmpty { s.steps = st }
                let agent = e.agent ?? ""
                switch e.event {
                case "spawn":
                    s.subagents[agent] = Subagent(id: agent, lastTool: "", lastLine: e.detail, done: false)
                case "subagent_stop":
                    s.subagents[agent, default: Subagent(id: agent, lastTool: "", lastLine: "", done: true)].done = true
                    s.subagents[agent]?.lastLine = e.detail
                case "note":
                    s.notes.append((agent.isEmpty ? "" : "[\(agent)] ") + e.detail)
                    if !agent.isEmpty { s.subagents[agent]?.lastLine = e.detail }
                case "tool":
                    if agent.isEmpty { s.lastTool = e.detail.isEmpty ? e.tool : e.detail }
                    else { s.subagents[agent, default: Subagent(id: agent, lastTool: "", lastLine: "", done: false)].lastTool = e.detail.isEmpty ? e.tool : e.detail }
                case "stop": s.lastLine = e.detail
                case "waiting": s.lastLine = e.detail
                default: break
                }
                if e.event != "note" && e.event != "steps" { s.state = e.state }
            }
            // Drop sessions idle or completed for more than 2 hours.
            if ["idle", "completed"].contains(s.state), let u = s.updatedAt, Date().timeIntervalSince(u) > 7200 { continue }
            if s.state == "waiting" && !notified.contains(s.id) { notify(s); notified.insert(s.id) }
            if s.state != "waiting" { notified.remove(s.id) }
            out.append(s)
        }
        sessions = out.sorted { ($0.updatedAt ?? .distantPast) > ($1.updatedAt ?? .distantPast) }
    }

    private func notify(_ s: Session) {
        let c = UNMutableNotificationContent()
        c.title = "Agent waiting: \(s.label)"
        c.body = s.lastLine.isEmpty ? s.title : s.lastLine
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: s.id + s.updatedAt.map { "\($0)" }!, content: c, trigger: nil))
    }
}

func glyph(_ state: String) -> String {
    switch state { case "waiting": return "◐"; case "working": return "●"; case "failed": return "✕"; case "completed": return "✓"; default: return "○" }
}
func elapsed(_ from: Date?) -> String {
    guard let f = from else { return "" }
    let m = Int(Date().timeIntervalSince(f) / 60); return m < 60 ? "\(m)m" : "\(m / 60)h\(m % 60)m"
}

@main
struct AgentBarApp: App {
    @StateObject private var store = StatusStore()
    init() { UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in } }

    var body: some Scene {
        MenuBarExtra {
            if store.sessions.isEmpty { Text("No active sessions") }
            ForEach(store.sessions) { s in
                Menu {
                    Text(s.title.isEmpty ? s.branch : s.title)
                    Text(s.lastTool.isEmpty ? s.state : s.lastTool).font(.caption)
                    if !s.steps.isEmpty {
                        Divider(); Text("Steps")
                        ForEach(s.steps, id: \.self) { st in
                            Text((st.state == "current" ? "▶ " : st.state == "done" ? "✓ " : "   ") + st.text)
                                .fontWeight(st.state == "current" ? .bold : .regular)
                        }
                    }
                    if !s.subagents.isEmpty {
                        Divider(); Text("Subagents")
                        ForEach(s.subagents.values.sorted { $0.id < $1.id }) { a in
                            Text("\(a.done ? "○" : "●") \(a.id)  \(a.done ? a.lastLine : a.lastTool)").font(.caption)
                        }
                    }
                    if !s.notes.isEmpty {
                        Divider(); Text("Notes")
                        ForEach(s.notes.suffix(8), id: \.self) { n in Text(n).font(.caption) }
                    }
                    Divider()
                    Button("Open worktree") { NSWorkspace.shared.open(URL(fileURLWithPath: s.root)) }
                } label: {
                    Text("\(glyph(s.state)) \(s.label)  \(s.title.isEmpty ? "" : s.title)  \(elapsed(s.startedAt))")
                }
            }
            Divider()
            Button("Quit") { NSApplication.shared.terminate(nil) }
        } label: {
            let waiting = store.sessions.filter { $0.state == "waiting" }.count
            let working = store.sessions.filter { $0.state == "working" }.count
            Text(waiting > 0 ? "◐\(waiting) ●\(working)" : "●\(working)")
        }
        .menuBarExtraStyle(.menu)
    }
}

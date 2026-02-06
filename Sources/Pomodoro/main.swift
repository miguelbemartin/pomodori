import Cocoa
import UserNotifications

class PomodoroTimer {
    enum State {
        case idle
        case running
        case paused
    }

    enum Session {
        case work
        case shortBreak

        var duration: TimeInterval {
            switch self {
            case .work: return 25 * 60
            case .shortBreak: return 5 * 60
            }
        }

        var label: String {
            switch self {
            case .work: return "Work"
            case .shortBreak: return "Break"
            }
        }

        var next: Session {
            switch self {
            case .work: return .shortBreak
            case .shortBreak: return .work
            }
        }
    }

    var state: State = .idle
    var session: Session = .work
    var remainingSeconds: TimeInterval = 25 * 60
    var timer: Timer?
    var onTick: (() -> Void)?
    var onComplete: (() -> Void)?

    func start() {
        state = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func pause() {
        state = .paused
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        state = .idle
        remainingSeconds = session.duration
        onTick?()
    }

    func skip() {
        timer?.invalidate()
        timer = nil
        session = session.next
        remainingSeconds = session.duration
        state = .idle
        onTick?()
    }

    private func tick() {
        remainingSeconds -= 1
        if remainingSeconds <= 0 {
            timer?.invalidate()
            timer = nil
            onComplete?()
            session = session.next
            remainingSeconds = session.duration
            state = .idle
        }
        onTick?()
    }

    var displayString: String {
        let mins = Int(remainingSeconds) / 60
        let secs = Int(remainingSeconds) % 60
        let icon = session == .work ? "🍅" : "☕"

        switch state {
        case .idle:
            return "\(icon) \(String(format: "%02d:%02d", mins, secs))"
        case .running:
            return "\(icon) \(String(format: "%02d:%02d", mins, secs))"
        case .paused:
            return "\(icon) ⏸ \(String(format: "%02d:%02d", mins, secs))"
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    let pomodoro = PomodoroTimer()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        pomodoro.onTick = { [weak self] in
            self?.updateDisplay()
        }
        pomodoro.onComplete = { [weak self] in
            self?.notifyCompletion()
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        updateDisplay()
        buildMenu()
    }

    func updateDisplay() {
        statusItem.button?.title = pomodoro.displayString
        buildMenu()
    }

    func buildMenu() {
        let menu = NSMenu()

        let sessionLabel = NSMenuItem(title: "\(pomodoro.session.label) Session", action: nil, keyEquivalent: "")
        sessionLabel.isEnabled = false
        menu.addItem(sessionLabel)
        menu.addItem(.separator())

        switch pomodoro.state {
        case .idle:
            menu.addItem(NSMenuItem(title: "Start", action: #selector(startTimer), keyEquivalent: "s"))
        case .running:
            menu.addItem(NSMenuItem(title: "Pause", action: #selector(pauseTimer), keyEquivalent: "p"))
        case .paused:
            menu.addItem(NSMenuItem(title: "Resume", action: #selector(startTimer), keyEquivalent: "s"))
        }

        menu.addItem(NSMenuItem(title: "Reset", action: #selector(resetTimer), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Skip to \(pomodoro.session.next.label)", action: #selector(skipSession), keyEquivalent: "k"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        statusItem.menu = menu
    }

    func notifyCompletion() {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro"
        content.body = pomodoro.session == .work
            ? "Break is over — time to focus!"
            : "Great work! Take a break."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
        NSSound.beep()
    }

    @objc func startTimer() {
        pomodoro.start()
        updateDisplay()
    }

    @objc func pauseTimer() {
        pomodoro.pause()
        updateDisplay()
    }

    @objc func resetTimer() {
        pomodoro.reset()
    }

    @objc func skipSession() {
        pomodoro.skip()
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

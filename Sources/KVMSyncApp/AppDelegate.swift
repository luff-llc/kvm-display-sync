import AppKit

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private weak var mainWindow: NSWindow?

    override init() {
        super.init()
        UserDefaults.standard.register(defaults: ["showDockIcon": true, "showMenuBarIcon": true])
    }

    static func applyActivationPolicy() {
        NSApplication.shared.setActivationPolicy(UserDefaults.standard.bool(forKey: "showDockIcon") ? .regular : .accessory)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.applyActivationPolicy()
    }

    func track(_ window: NSWindow) {
        mainWindow = window
        window.delegate = self
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard sender === mainWindow else { return true }
        sender.orderOut(nil)
        return false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        mainWindow?.makeKeyAndOrderFront(nil)
        sender.activate(ignoringOtherApps: true)
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

import SwiftUI

struct MenuContent: View {
    let model: SyncModel
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        Text(model.running ? "Automatic sync is running" : model.installed ? "Sync is paused" : "Setup required")
        Button("Open KVM Display Sync", action: showApp)
        if model.installed {
            Button(model.running ? "Pause Until Next Login" : "Resume Sync", action: model.toggle).disabled(model.busy)
            Button("Open Log", action: model.logs)
        }
        Divider()
        SettingsLink { Text("Settings…") }
        Button("Quit App") { NSApplication.shared.terminate(nil) }
    }
    private func showApp() { openWindow(id: "main"); NSApplication.shared.activate(ignoringOtherApps: true) }
}

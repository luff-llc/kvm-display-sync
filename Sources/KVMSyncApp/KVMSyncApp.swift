import SwiftUI

@main struct KVMSyncApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true
    @State private var model = SyncModel()
    var body: some Scene {
        WindowGroup("KVM Display Sync", id: "main") {
            Dashboard(model: model)
                .background(WindowBridge(delegate: appDelegate))
                .task { await model.poll() }
        }
        .defaultSize(width: 680, height: 650)
        .windowResizability(.contentSize)
        Settings {
            AppearanceSettings()
        }
        MenuBarExtra("KVM Display Sync", systemImage: model.running ? "display.2" : "display", isInserted: $showMenuBarIcon) {
            MenuContent(model: model)
        }
    }
}

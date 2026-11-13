import SwiftUI

@main struct KVMSyncApp: App {
    @State private var model = SyncModel()
    var body: some Scene {
        WindowGroup("KVM Display Sync", id: "main") {
            Dashboard(model: model)
                .task { await model.poll() }
        }
        .defaultSize(width: 680, height: 650)
        .windowResizability(.contentSize)
        MenuBarExtra("KVM Display Sync", systemImage: model.running ? "display.2" : "display") {
            MenuContent(model: model)
        }
    }
}

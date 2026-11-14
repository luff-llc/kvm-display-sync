import SwiftUI

struct SetupView: View {
    @Bindable var model: SyncModel
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Connect your KVM").font(.title3.bold())
            Text(model.message).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            if model.stage <= 0 {
                Picker("Monitor", selection: $model.selectedMonitor) {
                    ForEach(model.monitors) { Text($0.name).tag($0.id) }
                }
                Button("Refresh Displays", action: model.refreshDisplays)
                Button("Capture USB Devices on This Mac", systemImage: "usb.port", action: model.captureBaseline)
                    .buttonStyle(.borderedProminent)
            } else if model.stage == 1 {
                Label("Step 2 of 3 · Switch away", systemImage: "arrow.right")
                Button("Compare USB Devices", action: model.compare).buttonStyle(.borderedProminent)
                Button("Start Over", action: model.restartSetup)
            } else if model.stage == 2 {
                Label("Step 3 of 3 · Switch back", systemImage: "arrow.left")
                Picker("Monitor USB device", selection: $model.selectedUSB) {
                    ForEach(model.devices) { Text($0.title).tag($0.id) }
                }
                Button("Enable Automatic Sync", systemImage: "checkmark", action: model.enable).buttonStyle(.borderedProminent)
                Button("Start Over", action: model.restartSetup)
            }
        }.disabled(model.busy)
    }
}

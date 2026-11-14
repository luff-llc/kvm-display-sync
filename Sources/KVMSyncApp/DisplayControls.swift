import SwiftUI
import Typecase

struct DisplayControls: View {
    let model: SyncModel
    @Binding var confirmRemoval: Bool

    var body: some View {
        FloatingToolbar {
            if model.busy { ProgressView().controlSize(.small).tint(.white) }
            if model.installed {
                Button(model.running ? "Pause" : "Resume", systemImage: model.running ? "pause.fill" : "play.fill", action: model.toggle)
                    .buttonStyle(Typecase.CapsuleButtonStyle(.solid)).disabled(model.busy)
            }
            SettingsLink { Label("Settings", systemImage: "gearshape") }
                .buttonStyle(.borderless).foregroundStyle(Ink.primary).padding(.horizontal, 8)
            Menu("More", systemImage: "ellipsis") {
                if model.installed {
                    Button("Open Log", action: model.logs)
                    Button("Set Up Again", action: model.restartSetup)
                    Button("Uninstall Service", role: .destructive) { confirmRemoval = true }
                }
                Divider()
                Button("Quit App") { NSApplication.shared.terminate(nil) }
            }
            .menuStyle(.borderlessButton).fixedSize().foregroundStyle(Ink.primary)
        }
    }
}

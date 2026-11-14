import SwiftUI
import Typecase

struct Dashboard: View {
    @Bindable var model: SyncModel
    @Environment(\.typecaseTheme) private var theme
    @State private var confirmRemoval = false

    var body: some View {
        ContentRoom(palette: theme.palette(for: model.managedDisplayName), active: false) {
            ScrollView {
                VStack(spacing: 28) {
                    DisplayIdentity(name: model.managedDisplayName, running: model.running, installed: model.installed)
                    if !model.installed || (0...2).contains(model.stage) {
                        SetupView(model: model)
                            .padding(24)
                            .typecaseGlass(in: RoundedRectangle(cornerRadius: 26))
                    } else {
                        RecoveryExplanation()
                    }
                    if let error = model.error {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(Ink.body).textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if model.installed {
                        DisclosureGroup("Service details") {
                            Text(model.status).font(.system(.caption, design: .monospaced))
                                .foregroundStyle(Ink.secondary).textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 12)
                        }
                        .foregroundStyle(Ink.secondary)
                    }
                    Link("By LUFF · Source on GitHub", destination: URL(string: "https://github.com/luff-llc/kvm-display-sync")!)
                        .font(.caption).foregroundStyle(Ink.caption)
                }
                .frame(maxWidth: 520).padding(.horizontal, 28).padding(.top, 28).padding(.bottom, 18)
                .frame(maxWidth: .infinity)
            }
            .safeAreaInset(edge: .bottom) {
                DisplayControls(model: model, confirmRemoval: $confirmRemoval).padding(.bottom, 24).padding(.top, 12)
            }
        }
        .typecaseTheme(AppTheme.theme)
        .frame(width: 640, height: 690)
        .alert("Uninstall the background service?", isPresented: $confirmRemoval) {
            Button("Uninstall", role: .destructive, action: model.remove)
            Button("Cancel", role: .cancel) { }
        } message: { Text("The display layout will be restored and automatic sync will stop. You can set it up again from this app.") }
    }
}

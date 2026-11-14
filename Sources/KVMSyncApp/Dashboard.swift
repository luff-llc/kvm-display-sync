import SwiftUI

struct Dashboard: View {
    @Bindable var model: SyncModel
    @State private var confirmRemoval = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 18) {
                    Image(systemName: "display.2")
                        .font(.system(size: 34, weight: .medium)).foregroundStyle(LUFFTheme.accent).accessibilityHidden(true)
                        .frame(width: 76, height: 76)
                        .background(LUFFTheme.stage, in: .rect(cornerRadius: 14))
                        .overlay { RoundedRectangle(cornerRadius: 14).stroke(LUFFTheme.line) }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("LUFF / UTILITIES").font(.caption.weight(.semibold)).tracking(2).foregroundStyle(LUFFTheme.accent)
                        Text("KVM Display Sync").font(.custom("Georgia", size: 30, relativeTo: .title))
                        Text("Keep your desktop in place.").foregroundStyle(LUFFTheme.muted)
                    }
                    Spacer()
                }
                HStack {
                    Label(model.running ? "Sync is running" : model.installed ? "Sync is paused" : "Ready to set up",
                          systemImage: model.running ? "checkmark.circle.fill" : "circle.dashed")
                        .foregroundStyle(model.running ? LUFFTheme.accent : LUFFTheme.muted).font(.headline)
                    Spacer()
                    if model.busy { ProgressView().controlSize(.small) }
                    if model.installed {
                        Button(model.running ? "Pause" : "Resume", action: model.toggle).disabled(model.busy)
                    }
                }
                .padding(16).background(LUFFTheme.surface, in: .rect(cornerRadius: 10))
                .overlay { RoundedRectangle(cornerRadius: 10).stroke(LUFFTheme.line) }
                if !model.installed || (0...2).contains(model.stage) {
                    SetupView(model: model)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Display protection").font(.headline)
                        Text("When your KVM switches away, the monitor mirrors the built-in display so windows stay reachable. When it returns, your saved arrangement is restored.")
                            .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                        Label("Starts automatically at login", systemImage: "arrow.trianglehead.clockwise")
                        Label("Keeps running when this app quits", systemImage: "gearshape.2")
                        Text("Pause lasts until you resume or log in again.").font(.caption).foregroundStyle(.secondary)
                    }
                }
                if let error = model.error {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red).textSelection(.enabled).fixedSize(horizontal: false, vertical: true)
                }
                if model.installed {
                    DisclosureGroup("Service details") {
                        Text(model.status).font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 10)
                    }
                    HStack {
                        Button("Open Log", systemImage: "doc.text", action: model.logs)
                        Button("Set Up Again", action: model.restartSetup)
                        Spacer()
                        Button("Uninstall Service", role: .destructive) { confirmRemoval = true }
                    }.disabled(model.busy)
                }
                Divider()
                HStack {
                    Text("KVM Display Sync · By LUFF").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Link("Source", destination: URL(string: "https://github.com/luff-llc/kvm-display-sync")!).font(.caption)
                    Link("Original by AtakanMavzer", destination: URL(string: "https://github.com/AtakanMavzer/kvm-display-sync")!).font(.caption)
                }
            }.padding(30)
        }
        .frame(width: 680).frame(minHeight: 560, maxHeight: 820)
        .foregroundStyle(LUFFTheme.ink)
        .background(LUFFTheme.paper)
        .tint(LUFFTheme.accent)
        .toolbar {
            SettingsLink { Label("Settings", systemImage: "gearshape") }
        }
        .alert("Uninstall the background service?", isPresented: $confirmRemoval) {
            Button("Uninstall", role: .destructive, action: model.remove)
            Button("Cancel", role: .cancel) { }
        } message: { Text("The display layout will be restored and automatic sync will stop. You can set it up again from this app.") }
    }
}

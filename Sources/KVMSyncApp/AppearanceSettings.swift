import SwiftUI

struct AppearanceSettings: View {
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true
    @AppStorage("showDockIcon") private var showDockIcon = true

    var body: some View {
        Form {
            Section("Appearance") {
                Toggle("Show menu bar icon", isOn: $showMenuBarIcon)
                Toggle("Show Dock icon", isOn: $showDockIcon)
                    .onChange(of: showDockIcon) { AppDelegate.applyActivationPolicy() }
            }
            Section {
                Text("You can hide both icons. Open KVM Display Sync from Applications whenever you need its window or settings. Automatic sync continues in the background.")
                    .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
        .formStyle(.grouped)
        .tint(LUFFTheme.accent)
        .frame(width: 440)
        .padding(12)
    }
}

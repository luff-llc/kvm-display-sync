import SwiftUI
import Typecase

struct DisplayIdentity: View {
    let name: String
    let running: Bool
    let installed: Bool
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(spacing: 18) {
            Text("KVM Display Sync").eyebrow().foregroundStyle(Ink.eyebrow)
            if !typeSize.isAccessibilitySize {
                Image(systemName: "display.2")
                    .font(.system(size: 44, weight: .light)).foregroundStyle(Ink.primary)
                    .frame(width: 100, height: 100)
                    .typecaseGlass(in: Circle())
                    .accessibilityHidden(true)
            }
            VStack(spacing: 8) {
                Text(running ? "Everything in place." : "Ready when you are.")
                    .font(.screenHeading).foregroundStyle(Ink.primary)
                Text(name).font(.readingContent(.title3)).foregroundStyle(Ink.secondary)
            }
            .multilineTextAlignment(.center)
            Label(running ? "Automatic sync is on" : installed ? "Sync is paused" : "Let’s connect your display",
                  systemImage: running ? "checkmark.circle.fill" : "circle.dashed")
                .font(.callout.weight(.semibold)).foregroundStyle(Ink.body)
        }
        .accessibilityElement(children: .combine)
    }
}

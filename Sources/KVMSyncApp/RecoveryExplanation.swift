import SwiftUI
import Typecase

struct RecoveryExplanation: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("When you switch away", systemImage: "arrow.up.right")
                .font(.sectionHeading).foregroundStyle(Ink.primary)
            Text("Your monitor mirrors the built-in screen, keeping windows and the pointer within reach.")
                .font(.callout).foregroundStyle(Ink.body)
            Divider().overlay(Ink.eyebrow.opacity(0.3))
            Label("When you come back", systemImage: "arrow.down.left")
                .font(.sectionHeading).foregroundStyle(Ink.primary)
            Text("Your display arrangement returns. Sync starts at login and keeps working when this window closes.")
                .font(.callout).foregroundStyle(Ink.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .typecaseGlass(in: RoundedRectangle(cornerRadius: 26))
    }
}

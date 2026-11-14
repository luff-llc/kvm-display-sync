import AppKit
import SwiftUI
import Typecase

// Taupe's host-owned accent; room colors come from the managed display's identity.
enum AppTheme {
    static let accent = Color(nsColor: NSColor(name: nil) { appearance in
        if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            NSColor(srgbRed: 0.788, green: 0.714, blue: 0.647, alpha: 1)
        } else {
            NSColor(srgbRed: 0.431, green: 0.365, blue: 0.314, alpha: 1)
        }
    })
    static let theme = Theme(accent: accent, seededFallbackHue: 0.10)
}

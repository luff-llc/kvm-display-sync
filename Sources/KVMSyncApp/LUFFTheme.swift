import AppKit
import SwiftUI

// Palette from luff-llc/luff.works/app/blue-brand.css. Georgia is LUFF's
// declared serif fallback; controls retain the native macOS system font.
enum LUFFTheme {
    static let accent = adaptive(light: 0x2455D5, dark: 0x92B1FF)
    static let paper = adaptive(light: 0xF5F7FC, dark: 0x10192B)
    static let surface = adaptive(light: 0xFFFFFF, dark: 0x19263B)
    static let ink = adaptive(light: 0x142443, dark: 0xE9EFFF)
    static let muted = adaptive(light: 0x566880, dark: 0xB1C1DC)
    static let line = adaptive(light: 0xD0DAEB, dark: 0x34445E)
    static let stage = adaptive(light: 0xEEF3FF, dark: 0x22365A)

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let hex = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
            return NSColor(srgbRed: Double((hex >> 16) & 255) / 255,
                           green: Double((hex >> 8) & 255) / 255,
                           blue: Double(hex & 255) / 255, alpha: 1)
        })
    }
}

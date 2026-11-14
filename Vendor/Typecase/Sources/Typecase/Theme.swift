// Ported from Marginalia/apps/apple/App/Shell/Theme.swift@24297cfe
import SwiftUI

/// Brand choices stay with the host app, not with individual components.
public struct Theme: Sendable {
  public var accent: Color
  public var seededFallbackHue: Double
  public var readingTypeface: ReadingTypeface
  public var headingDesign: Font.Design

  public init(
    accent: Color = .accentColor,
    seededFallbackHue: Double = 0.62,
    readingTypeface: ReadingTypeface = .init(body: .serif, heading: .serif),
    headingDesign: Font.Design = .default
  ) {
    self.accent = accent
    self.seededFallbackHue = seededFallbackHue.isFinite
      ? (seededFallbackHue.truncatingRemainder(dividingBy: 1) + 1).truncatingRemainder(dividingBy: 1)
      : 0.62
    self.readingTypeface = readingTypeface
    self.headingDesign = headingDesign
  }

  public func palette(for name: String) -> ContentPalette {
    ContentPalette.seeded(name, fallbackHue: seededFallbackHue)
  }
}

private struct ThemeKey: EnvironmentKey {
  static let defaultValue = Theme()
}

extension EnvironmentValues {
  public var typecaseTheme: Theme {
    get { self[ThemeKey.self] }
    set { self[ThemeKey.self] = newValue }
  }
}

extension View {
  /// The host chooses the brand. A nested room can still take its hue from content.
  public func typecaseTheme(_ theme: Theme) -> some View {
    environment(\.typecaseTheme, theme)
  }
}

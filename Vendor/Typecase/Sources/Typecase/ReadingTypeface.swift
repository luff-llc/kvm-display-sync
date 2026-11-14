// Extracted from Typecase/Sources/Typecase/ReadingPassage.swift@36ef6a1
import SwiftUI

/// A face for reading text: the system's, or a named family the system ships.
public enum ReadingFace: Equatable, Sendable {
  case serif, sans, mono, rounded
  /// A family name such as "Georgia". The app checks the family is installed before using it.
  case family(String)

  public func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    switch self {
    case .serif: .system(size: size, weight: weight, design: .serif)
    case .sans: .system(size: size, weight: weight, design: .default)
    case .mono: .system(size: size, weight: weight, design: .monospaced)
    case .rounded: .system(size: size, weight: weight, design: .rounded)
    case .family(let name): .custom(name, fixedSize: size).weight(weight)
    }
  }
}

/// A publication's type for passages: its text face, its heading face and weight, and how
/// open its lines are.
public struct ReadingTypeface: Equatable, Sendable {
  public var body: ReadingFace
  public var heading: ReadingFace
  public var headingBold: Bool
  public var leading: CGFloat

  public init(body: ReadingFace, heading: ReadingFace, headingBold: Bool = true, leading: CGFloat = 0.3) {
    self.body = body; self.heading = heading; self.headingBold = headingBold; self.leading = leading
  }
}

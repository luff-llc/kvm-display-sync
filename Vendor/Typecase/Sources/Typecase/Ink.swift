// Ported from Marginalia/packages/MarginaliaDesign/Sources/MarginaliaDesign/MarginInk.swift@24297cfe
import SwiftUI

/// White text on content colour, at the only opacities the design uses. The palette's
/// brightness clamp (0.20–0.60) is what keeps each of these readable.
public enum Ink {
  /// Titles and primary values.
  public static let primary = Color.white
  /// Running text such as summaries and show notes.
  public static let body = Color.white.opacity(0.85)
  /// Secondary lines: sources, authors.
  public static let secondary = Color.white.opacity(0.75)
  /// Captions and times.
  public static let caption = Color.white.opacity(0.7)
  /// Section eyebrows.
  public static let eyebrow = Color.white.opacity(0.6)
  /// Receding text, such as transcript lines that are not current.
  public static let receding = Color.white.opacity(0.42)
}

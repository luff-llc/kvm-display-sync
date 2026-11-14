// Ported from Marginalia/packages/MarginaliaDesign/Sources/MarginaliaDesign/MarginType.swift@24297cfe
import SwiftUI

/// Marginalia's two voices (DESIGN.md §4). **Serif is what you read or wrote**: titles of works,
/// authors, passages, quotes, transcripts, notes and the names you gave things. **SF is how you
/// use the app**: screen and section headings, empty states, onboarding, guides, controls and
/// metadata, however large or warm. These are the only places the app asks for New York;
/// `tools/check-typography.sh` rejects `design: .serif` anywhere else.
extension Font {
  /// Content, in New York, at a Dynamic Type style.
  public static func readingContent(_ style: Font.TextStyle = .body) -> Font {
    .system(style, design: .serif)
  }

  /// Content, in New York, at a fixed size (covers, page thumbnails and other drawn objects).
  public static func readingContent(size: CGFloat, weight: Font.Weight = .regular) -> Font {
    .system(size: size, weight: weight, design: .serif)
  }

  /// A screen's own heading, when it draws one instead of a navigation title.
  public static let screenHeading = Font.largeTitle.weight(.bold)

  /// A heading within a screen. ``SectionHeader`` uses it.
  public static let sectionHeading = Font.title3.weight(.bold)
}

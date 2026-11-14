// Ported from Marginalia/packages/MarginaliaDesign/Sources/MarginaliaDesign/MarginEyebrow.swift@24297cfe
import SwiftUI

/// The small uppercase label above a title: `.caption` semibold, tracked 0.7. It inherits
/// its colour and line limit, so the host chooses `.secondary`, a publication colour or
/// `Ink.eyebrow` on colour, and keeps it to one line except at accessibility sizes.
public struct Eyebrow: ViewModifier {
  public init() {}
  public func body(content: Content) -> some View {
    content
      .font(.caption.weight(.semibold))
      .textCase(.uppercase)
      .tracking(0.7)
  }
}

extension View {
  /// Styles text as an eyebrow. See ``Eyebrow``.
  public func eyebrow() -> some View { modifier(Eyebrow()) }
}

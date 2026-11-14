// Ported from Marginalia/packages/MarginaliaDesign/Sources/MarginaliaDesign/MarginGlass.swift@24297cfe
import SwiftUI

private struct GlassChrome<S: Shape>: ViewModifier {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  let shape: S
  let interactive: Bool
  let tint: Color?

  @ViewBuilder func body(content: Content) -> some View {
    #if os(visionOS)
      // Spatial glass belongs to the window's volume; never emulate with flat panels.
      content.glassBackgroundEffect(in: shape)
    #else
      if #available(iOS 26.0, macOS 26.0, *) {
        // The platform owns Reduce Transparency and Increase Contrast adaptation.
        content.glassEffect(interactive ? .regular.tint(tint).interactive() : .regular.tint(tint), in: shape)
      } else if reduceTransparency {
        content.background(.thickMaterial, in: shape).background(tint ?? .clear, in: shape)
      } else {
        content.background(.ultraThinMaterial, in: shape).background(tint ?? .clear, in: shape)
      }
    #endif
  }
}

extension View {
  /// Native glass on Apple 26+, material fallbacks on earlier operating systems.
  public func typecaseGlass<S: Shape>(in shape: S, interactive: Bool = false, tint: Color? = nil) -> some View {
    modifier(GlassChrome(shape: shape, interactive: interactive, tint: tint))
  }
}

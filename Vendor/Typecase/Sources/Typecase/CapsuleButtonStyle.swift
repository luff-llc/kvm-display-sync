// Ported from Marginalia/packages/MarginaliaDesign/Sources/MarginaliaDesign/MarginCapsuleButtonStyle.swift@24297cfe
import SwiftUI

/// Labelled capsule controls. `.solid` is the white resume capsule on a content-tinted card;
/// `.glass` floats on imagery; `.tinted` is a quiet chip for plain pages, filled when
/// selected.
public struct CapsuleButtonStyle: ButtonStyle {
  public enum Prominence: Sendable { case solid, glass, tinted }
  private let prominence: Prominence
  private let selected: Bool

  public init(_ prominence: Prominence = .solid, selected: Bool = false) {
    self.prominence = prominence
    self.selected = selected
  }

  public func makeBody(configuration: Configuration) -> some View {
    CapsuleBody(configuration: configuration, prominence: prominence, selected: selected)
  }

  private struct CapsuleBody: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let configuration: ButtonStyleConfiguration
    let prominence: Prominence
    let selected: Bool

    var body: some View {
      styled
        .scaleEffect(configuration.isPressed && !reduceMotion ? 0.94 : 1)
        .opacity(configuration.isPressed ? 0.85 : 1)
        .animation(Motion.press.animation(reduced: reduceMotion),
          value: configuration.isPressed)
    }

    @ViewBuilder private var styled: some View {
      let label = configuration.label
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 16).padding(.vertical, 10)
        .contentShape(Capsule())
      switch prominence {
      case .solid:
        label.foregroundStyle(.black.opacity(0.85)).background(.white, in: Capsule())
      case .glass:
        label.foregroundStyle(.white).typecaseGlass(in: Capsule(), interactive: true)
      case .tinted:
        label
          .foregroundStyle(selected ? AnyShapeStyle(.background) : AnyShapeStyle(.primary))
          .background(
            selected ? AnyShapeStyle(.primary) : AnyShapeStyle(.quaternary), in: Capsule())
      }
    }
  }
}

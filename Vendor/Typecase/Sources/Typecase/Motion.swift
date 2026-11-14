// Ported from Marginalia/packages/MarginaliaDesign/Sources/MarginaliaDesign/MarginMotion.swift@24297cfe
import SwiftUI

/// The app's motion vocabulary (DESIGN.md §6), in one place. Every animation expresses a state
/// change; each has a name here instead of a number at the call site. Reduce Motion drops
/// movement: most motions become no animation, colour changes become a short cross-fade.
public enum Motion: Sendable {
  /// A glass or glyph control pressed.
  case press
  /// A card or tile pressed.
  case cardPress
  /// Something grabbed and held, such as the timeline.
  case grab
  /// Moving between stages or pages of a room.
  case stage
  /// Rows arriving or leaving within one list.
  case list
  /// A chip or segmented highlight moving to its new choice.
  case chip
  /// A list narrowing as a filter or search changes.
  case filter
  /// Controls folding away or unfolding when a stage expands.
  case fold
  /// Something coming to rest, such as a cover when playback pauses.
  case settle
  /// A title replaced, such as the current chapter.
  case title
  /// A banner or toast arriving from the bottom.
  case banner
  /// A menu blooming out of the control that opened it.
  case bloom
  /// Something unfolding in place, such as notes under a passage.
  case reveal
  /// Reading chrome hiding or returning as you scroll.
  case chrome
  /// Scrolling to keep the line being spoken in view.
  case follow
  /// The current line or item brightening as playback reaches it.
  case current
  /// A small control changing state, such as the transcript's follow button.
  case toggle
  /// A tint or palette changing.
  case tint
  /// A room's backdrop changing colour. Always a cross-fade, never movement.
  case backdrop
  /// A character at rest, breathing slowly, for as long as it's on screen.
  case breath
  /// A character climbing into view, such as Taupe's mole out of its burrow.
  case emerge
  /// A character's eyes closing or opening in a blink.
  case blink
  /// A character leaning one way, then the other, to what it hears.
  case sway
  /// Bundled welcome covers rising into their arc.
  case coverRise
  /// A settled welcome cover drifting gently in place.
  case coverDrift

  public var animation: Animation {
    switch self {
    case .press: .spring(response: 0.28, dampingFraction: 0.62)
    case .cardPress, .grab: .spring(response: 0.3, dampingFraction: 0.7)
    case .stage: .smooth(duration: 0.5)
    case .list: .smooth(duration: 0.45)
    case .chip: .smooth(duration: 0.4)
    case .filter: .smooth(duration: 0.35)
    case .fold: .spring(response: 0.5, dampingFraction: 0.86)
    case .settle: .spring(response: 0.55, dampingFraction: 0.68)
    case .title: .spring(response: 0.45, dampingFraction: 0.8)
    case .banner: .spring(response: 0.4, dampingFraction: 0.8)
    case .bloom: .spring(duration: 0.42, bounce: 0.22)
    case .reveal: .spring(response: 0.4, dampingFraction: 0.85)
    case .chrome: .smooth(duration: 0.3)
    case .follow: .smooth(duration: 0.5)
    case .current: .smooth(duration: 0.35)
    case .toggle: .spring(response: 0.35, dampingFraction: 0.75)
    case .tint: .easeInOut(duration: 0.6)
    case .backdrop: .easeInOut(duration: 0.9)
    case .breath: .easeInOut(duration: 2.1).repeatForever(autoreverses: true)
    case .emerge: .spring(response: 0.75, dampingFraction: 0.7).delay(0.12)
    case .blink: .linear(duration: 0.08)
    case .sway: .easeInOut(duration: 1.05)
    case .coverRise: .spring(response: 0.7, dampingFraction: 0.72)
    case .coverDrift: .easeInOut(duration: 3.2).repeatForever(autoreverses: true)
    }
  }

  /// The animation to use when Reduce Motion is `reduced`: none for movement, a short
  /// cross-fade for colour.
  public func animation(reduced: Bool) -> Animation? {
    guard reduced else { return animation }
    switch self {
    case .backdrop, .tint: return .easeInOut(duration: 0.25)
    default: return nil
    }
  }

  /// A small delay for the `index`th item of something that arrives in sequence, such as the
  /// rows of a bloom. Nothing is staggered under Reduce Motion.
  public func staggered(_ index: Int, reduced: Bool) -> Animation? {
    animation(reduced: reduced)?.delay(reduced ? 0 : Double(index) * 0.035)
  }
}

private struct MarginAnimation<Value: Equatable>: ViewModifier {
  let motion: Motion
  let value: Value
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  func body(content: Content) -> some View {
    content.animation(motion.animation(reduced: reduceMotion), value: value)
  }
}

extension View {
  /// Animates changes to `value` with a named motion, honouring Reduce Motion.
  public func namedAnimation<Value: Equatable>(_ motion: Motion, value: Value) -> some View {
    modifier(MarginAnimation(motion: motion, value: value))
  }
}

/// Performs `body` with a named motion, honouring Reduce Motion (pass the environment's
/// `accessibilityReduceMotion`).
@MainActor public func withNamedAnimation<Result>(_ motion: Motion, reduced: Bool,
  _ body: () throws -> Result) rethrows -> Result {
  try withAnimation(motion.animation(reduced: reduced), body)
}

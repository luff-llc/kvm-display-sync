// Ported from Marginalia/apps/apple/App/Podcasts/PlayerBackdrop.swift@24297cfe
import SwiftUI

/// Content-coloured room background. Only a visible, active room drifts.
public struct RoomBackdrop: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.colorSchemeContrast) private var contrast
  @State private var visible = false
  @State private var pausedTime = Date.now.timeIntervalSinceReferenceDate

  public let palette: ContentPalette
  public var active: Bool

  public init(palette: ContentPalette, active: Bool = false) {
    self.palette = palette
    self.active = active
  }

  /// Exposed for verification; ambient motion never overrides Reduce Motion.
  nonisolated public static func shouldDrift(active: Bool, visible: Bool, sceneActive: Bool, reduceMotion: Bool) -> Bool {
    active && visible && sceneActive && !reduceMotion
  }

  private var drifting: Bool {
    Self.shouldDrift(active: active, visible: visible,
      sceneActive: scenePhase == .active, reduceMotion: reduceMotion)
  }

  public var body: some View {
    ZStack {
      if drifting {
        TimelineView(.periodic(from: .now, by: 1.0 / 12.0)) { context in
          mesh(at: context.date.timeIntervalSinceReferenceDate)
        }
      } else {
        mesh(at: pausedTime)
      }
      LinearGradient(
        colors: [
          .black.opacity(contrast == .increased ? 0.35 : 0.12),
          .black.opacity(contrast == .increased ? 0.44 : 0.22),
          .black.opacity(contrast == .increased ? 0.65 : 0.50),
        ],
        startPoint: .top, endPoint: .bottom
      )
    }
    .ignoresSafeArea()
    .allowsHitTesting(false)
    .accessibilityHidden(true)
    .namedAnimation(.backdrop, value: palette)
    .onAppear { visible = true }
    .onDisappear { visible = false }
    .onChange(of: drifting) { _, nowDrifting in
      if !nowDrifting { pausedTime = Date.now.timeIntervalSinceReferenceDate }
    }
  }

  @ViewBuilder private func mesh(at time: Double) -> some View {
    if #available(macOS 15, *) {
      MeshGradient(width: 3, height: 3, points: Self.points(at: time),
        colors: palette.mesh, smoothsColors: true)
    } else {
      LinearGradient(colors: [palette.colors[0], palette.colors[1], palette.colors[3]],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    }
  }

  /// Four corners remain fixed; interior and edge points move within 0.2.
  nonisolated public static func points(at time: Double) -> [SIMD2<Float>] {
    func drift(_ seconds: Double, _ phase: Double, _ amplitude: Float) -> Float {
      Float(sin(time * 2 * .pi / seconds + phase)) * amplitude
    }
    return [
      [0, 0], [0.5 + drift(23, 0, 0.18), 0], [1, 0],
      [0, 0.5 + drift(19, 1, 0.16)],
      [0.5 + drift(17, 2, 0.2), 0.5 + drift(29, 3, 0.2)],
      [1, 0.5 + drift(21, 4, 0.16)],
      [0, 1], [0.5 + drift(27, 5, 0.18), 1], [1, 1],
    ]
  }
}

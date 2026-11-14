// Ported from Marginalia/apps/apple/App/Podcasts/ListenRoom.swift@24297cfe
import SwiftUI

/// An immersive room owns the backdrop and its local dark appearance, never its data.
public struct ContentRoom<Content: View>: View {
  public let palette: ContentPalette
  public let active: Bool
  public let forcesDarkAppearance: Bool
  private let content: Content

  public init(
    palette: ContentPalette,
    active: Bool = false,
    forcesDarkAppearance: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.palette = palette
    self.active = active
    self.forcesDarkAppearance = forcesDarkAppearance
    self.content = content()
  }

  @ViewBuilder public var body: some View {
    let room = content
      .background { RoomBackdrop(palette: palette, active: active) }
      .scrollContentBackground(.hidden)
    if forcesDarkAppearance {
      room.environment(\.colorScheme, .dark)
    } else {
      room
    }
  }
}

/// Capsule background for a host-supplied row of real buttons and menus.
public struct FloatingToolbar<Content: View>: View {
  private let content: Content
  public init(@ViewBuilder content: () -> Content) { self.content = content() }

  public var body: some View {
    HStack(spacing: 8) { content }
      .padding(.horizontal, 14)
      .padding(.vertical, 9)
      .typecaseGlass(in: Capsule(), interactive: true)
      .accessibilityElement(children: .contain)
  }
}

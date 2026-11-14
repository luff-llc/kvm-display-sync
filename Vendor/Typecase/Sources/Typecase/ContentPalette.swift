// Ported from Marginalia/apps/apple/App/Podcasts/ArtworkPalette.swift@24297cfe
import CoreGraphics
import Foundation
import SwiftUI

/// HSB values of a colour drawn from artwork, normalized for white text on a room.
public struct PaletteTone: Equatable, Sendable {
  public let hue: Double
  public let saturation: Double
  public let brightness: Double

  public init(hue: Double, saturation: Double, brightness: Double) {
    let hue = hue.isFinite ? hue : 0
    self.hue = (hue.truncatingRemainder(dividingBy: 1) + 1).truncatingRemainder(dividingBy: 1)
    self.saturation = Self.clamp(saturation, lower: 0, upper: 0.82)
    self.brightness = Self.clamp(brightness, lower: 0.2, upper: 0.6)
  }

  public var color: Color {
    Color(hue: hue, saturation: saturation, brightness: brightness)
  }

  private static func clamp(_ value: Double, lower: Double, upper: Double) -> Double {
    value.isFinite ? min(upper, max(lower, value)) : lower
  }
}

/// Exactly four palette tones. Sampling is pure: callers retain and decode artwork.
public struct ContentPalette: Equatable, Sendable {
  public let tones: [PaletteTone]
  public var colors: [Color] { tones.map(\.color) }
  public var mesh: [Color] {
    let c = colors
    return [c[0], c[2], c[1], c[1], c[0], c[2], c[3], c[1], c[3]]
  }

  public init(tones: [PaletteTone]) {
    let supplied = tones.isEmpty ? [PaletteTone(hue: 0.62, saturation: 0.32, brightness: 0.34)] : tones
    var result = Array(supplied.prefix(4))
    while result.count < 4 {
      let base = supplied[result.count % supplied.count]
      result.append(PaletteTone(hue: base.hue,
        saturation: base.saturation * 0.9, brightness: base.brightness * 0.8))
    }
    self.tones = result
  }

  public static let fallback = seeded("", fallbackHue: 0.62)

  /// FNV-1a is stable across launches, architectures and Swift processes (unlike hashValue).
  public static func seeded(_ name: String, fallbackHue: Double = 0.62) -> ContentPalette {
    let normalized = name.precomposedStringWithCanonicalMapping.lowercased()
    var hash: UInt64 = 1_469_598_103_934_665_603
    for byte in normalized.utf8 {
      hash = (hash ^ UInt64(byte)) &* 1_099_511_628_211
    }
    let hue = normalized.isEmpty
      ? PaletteTone(hue: fallbackHue, saturation: 0.4, brightness: 0.46).hue
      : Double(hash % 360) / 360.0
    func shifted(_ offset: Double) -> Double {
      (hue + offset).truncatingRemainder(dividingBy: 1)
    }
    return ContentPalette(tones: [
      PaletteTone(hue: hue, saturation: 0.42, brightness: 0.46),
      PaletteTone(hue: shifted(0.04), saturation: 0.36, brightness: 0.32),
      PaletteTone(hue: shifted(0.93), saturation: 0.30, brightness: 0.55),
      PaletteTone(hue: hue, saturation: 0.40, brightness: 0.20),
    ])
  }

  /// Samples a CGImage into 12 × 12 pixels, selects distinct representative colours,
  /// and clamps them for readable foreground ink. No image loading or network I/O.
  public static func sampled(from image: CGImage) -> ContentPalette? {
    let side = 12
    var pixels = [UInt8](repeating: 0, count: side * side * 4)
    let rendered = pixels.withUnsafeMutableBytes { raw in
      guard let context = CGContext(
        data: raw.baseAddress, width: side, height: side, bitsPerComponent: 8,
        bytesPerRow: side * 4, space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
      else { return false }
      context.interpolationQuality = .medium
      context.draw(image, in: CGRect(x: 0, y: 0, width: side, height: side))
      return true
    }
    guard rendered else { return nil }
    return sampled(pixels: pixels)
  }

  /// Exposed separately to test sampling without depending on an image decoder.
  /// Input is a 12 × 12 RGBA8 grid with premultiplied or opaque RGB channels.
  public static func sampled(pixels: [UInt8]) -> ContentPalette? {
    guard pixels.count == 12 * 12 * 4 else { return nil }
    struct Bucket {
      var r = 0.0, g = 0.0, b = 0.0, count = 0.0
    }
    var buckets: [Int: Bucket] = [:]
    for index in stride(from: 0, to: pixels.count, by: 4) {
      let alpha = Double(pixels[index + 3]) / 255
      guard alpha > 0.03 else { continue }
      let r = min(1, Double(pixels[index]) / 255 / alpha)
      let g = min(1, Double(pixels[index + 1]) / 255 / alpha)
      let b = min(1, Double(pixels[index + 2]) / 255 / alpha)
      let key = Int(r * 3.99) * 16 + Int(g * 3.99) * 4 + Int(b * 3.99)
      var bucket = buckets[key] ?? Bucket()
      bucket.r += r; bucket.g += g; bucket.b += b; bucket.count += 1
      buckets[key] = bucket
    }
    var ranked: [(key: Int, tone: PaletteTone, weight: Double)] = []
    for (key, bucket) in buckets {
      let red: Double = bucket.r / bucket.count
      let green: Double = bucket.g / bucket.count
      let blue: Double = bucket.b / bucket.count
      let tone = Self.fromRGB(red, green, blue)
      let weight: Double = bucket.count * (0.35 + tone.saturation)
      ranked.append((key: key, tone: tone, weight: weight))
    }
    ranked.sort { a, b in
      a.weight == b.weight ? a.key < b.key : a.weight > b.weight
    }
    var selected: [PaletteTone] = []
    for entry in ranked where selected.count < 4 {
      let tone = entry.tone
      if selected.allSatisfy({ other in
        let gap = abs(tone.hue - other.hue)
        return min(gap, 1 - gap) * 2
          + abs(tone.brightness - other.brightness)
          + abs(tone.saturation - other.saturation) > 0.22
      }) {
        selected.append(PaletteTone(hue: tone.hue,
          saturation: tone.saturation * 1.1, brightness: tone.brightness * 0.85))
      }
    }
    return selected.isEmpty ? nil : ContentPalette(tones: selected)
  }

  private static func fromRGB(_ r: Double, _ g: Double, _ b: Double) -> PaletteTone {
    let high = max(r, g, b), low = min(r, g, b), delta = high - low
    var hue = 0.0
    if delta > 0 {
      if high == r { hue = ((g - b) / delta).truncatingRemainder(dividingBy: 6) }
      else if high == g { hue = (b - r) / delta + 2 }
      else { hue = (r - g) / delta + 4 }
      hue /= 6
      if hue < 0 { hue += 1 }
    }
    return PaletteTone(hue: hue,
      saturation: high > 0 ? delta / high : 0, brightness: high)
  }
}

/// Caller-keyed, bounded palette cache. A host does image work in the factory,
/// with concurrent requests for the same key sharing one in-flight computation.
public actor PaletteCache {
  private var values: [String: ContentPalette] = [:]
  private var insertionOrder: [String] = []
  private var pending: [String: Task<ContentPalette?, Never>] = [:]
  private let limit: Int

  public init(limit: Int = 512) { self.limit = max(1, limit) }

  public func cached(for key: String) -> ContentPalette? { values[key] }

  public func palette(
    for key: String,
    produce: @escaping @Sendable () async -> ContentPalette?
  ) async -> ContentPalette? {
    if let existing = values[key] { return existing }
    if let task = pending[key] { return await task.value }
    let task = Task { await produce() }
    pending[key] = task
    let result = await task.value
    pending[key] = nil
    if let result, values[key] == nil {
      values[key] = result
      insertionOrder.append(key)
      if insertionOrder.count > limit {
        let evicted = insertionOrder.removeFirst()
        values.removeValue(forKey: evicted)
      }
    }
    return result
  }

  public func removeAll() {
    values.removeAll()
    insertionOrder.removeAll()
    pending.removeAll()
  }
}

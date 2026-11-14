import AppKit

// Use the same standard macOS display symbol as the app's dashboard.
let folder = URL(fileURLWithPath: CommandLine.arguments[1])
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        let factor = CGFloat(pixels) / 1024
        NSAffineTransform().apply { transform in transform.scale(by: factor); transform.concat() }
        let tile = NSBezierPath(roundedRect: NSRect(x: 100, y: 100, width: 824, height: 824), xRadius: 180, yRadius: 180)
        NSGradient(starting: NSColor(red: 0.431, green: 0.365, blue: 0.314, alpha: 1),
                   ending: NSColor(red: 0.431, green: 0.365, blue: 0.314, alpha: 1))!.draw(in: tile, angle: -90)
        let symbol = NSImage(systemSymbolName: "display.2", accessibilityDescription: nil)!
            .withSymbolConfiguration(.init(paletteColors: [.white]))!
        let ratio = symbol.size.width / symbol.size.height
        let width: CGFloat = 580
        let height = width / ratio
        symbol.draw(in: NSRect(x: (1024-width)/2, y: (1024-height)/2, width: width, height: height))
        NSGraphicsContext.restoreGraphicsState()
        let suffix = scale == 2 ? "@2x" : ""
        try bitmap.representation(using: .png, properties: [:])!.write(to: folder.appendingPathComponent("icon_\(size)x\(size)\(suffix).png"))
    }
}

extension NSAffineTransform {
    func apply(_ body: (NSAffineTransform) -> Void) { body(self) }
}

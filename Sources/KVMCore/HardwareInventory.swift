import Foundation

/// IOKit / AppKit queries stay on the UI run loop. No command output is parsed.
@MainActor public enum HardwareInventory {
    public static func monitors() -> [Monitor] {
        Displays.online().map { info in
            Monitor(id: info.id, vendor: info.vendor, model: info.model, serial: info.serial,
                    name: Displays.name(for: info.id) ?? "Display \(info.id)", isBuiltin: info.isBuiltin)
        }
    }
    public static func usbDevices() -> [USBDevice] {
        USBWatcher.listAll().map { USBDevice(vendor: $0.vendor, product: $0.product, name: $0.name) }
    }
}

import CoreGraphics
import Testing
@testable import KVMCore

struct DisplayRecoveryTests {
    func display(_ id: UInt32, serial: UInt32 = 1, builtin: Bool = false, x: Int = 0, y: Int = 0) -> DisplayInfo {
        DisplayInfo(id: id, vendor: 1715, model: 13042, serial: serial, isBuiltin: builtin,
            isMain: !builtin, isActive: true, isOnline: true, mirrorOf: 0,
            bounds: CGRect(x: x, y: y, width: 1920, height: 1080))
    }

    @Test func identicalMonitorModelsRequireUnambiguousIdentity() {
        let monitors = [display(5, serial: 111), display(6, serial: 222)]
        #expect(Displays.select(monitors, vendor: 1715, model: 13042, serial: nil) == nil)
        #expect(Displays.select(monitors, vendor: 1715, model: 13042, serial: 222)?.id == 6)
    }

    @Test func builtinDisplayIsNeverSelectedAsExternal() {
        #expect(Displays.select([display(1, builtin: true)], vendor: 1715, model: 13042, serial: nil) == nil)
    }

    @Test func builtinPositionMustAlsoMatchBeforeSkippingRecovery() {
        let record = DisabledDisplay(id: 5, wasMain: true, originX: 0, originY: 0, builtinOriginX: 99, builtinOriginY: 1080)
        #expect(record.matches(external: display(5), builtin: display(1, builtin: true)) == false)
        #expect(record.matches(external: display(5), builtin: display(1, builtin: true, x: 99, y: 1080)))
    }

    @Test func usbIdentityHasStableFormatting() {
        let hub = USBDevice(vendor: 0x0BDA, product: 0x5411, name: "USB2.1 Hub")
        #expect(hub.id == "0x0BDA:0x5411")
        #expect(hub.title == "USB2.1 Hub · 0x0BDA:0x5411")
    }
}

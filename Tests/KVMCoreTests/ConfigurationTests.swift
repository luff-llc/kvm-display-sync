import Testing
@testable import KVMCore

struct ConfigurationTests {
    @Test(arguments: ["-1", "4294967296", "garbage"])
    func invalidDisplayIDReturnsError(_ value: String) {
        #expect(throws: UsageError.self) { try parse(["watch", "--display-vendor", value]) }
    }

    @Test(arguments: ["-1", "65536", "garbage"])
    func invalidUSBIDReturnsError(_ value: String) {
        #expect(throws: UsageError.self) { try parse(["watch", "--usb-product", value]) }
    }

    @Test(arguments: ["nan", "inf", "-1"])
    func invalidDebounceReturnsError(_ value: String) {
        #expect(throws: UsageError.self) { try parse(["watch", "--debounce", value]) }
    }

    @Test func configuredMonitorSurvivesLaunchArgumentsRoundTrip() throws {
        let (_, _, first) = try parse(["watch", "--usb-vendor", "0x0BDA", "--usb-product", "0x5411",
            "--display-vendor", "1715", "--display-model", "13042", "--display-serial", "16843009"])
        let (_, _, second) = try parse(["watch"] + first.watchArguments)
        #expect(second.usbVendor == 0x0BDA)
        #expect(second.usbProduct == 0x5411)
        #expect(second.displayVendor == 1715)
        #expect(second.displayModel == 13042)
        #expect(second.displaySerial == 16843009)
    }
}

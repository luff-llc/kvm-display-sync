import KVMCore
import AppKit
import Observation

@MainActor @Observable final class SyncModel {
    var monitors = HardwareInventory.monitors().filter { !$0.isBuiltin }
    var selectedMonitor: UInt32 = HardwareInventory.monitors().filter { !$0.isBuiltin }.first?.id ?? 0
    var devices: [USBDevice] = []
    var selectedUSB = ""
    var baseline: [USBDevice] = []
    var stage = -1
    var busy = false
    var message = "Choose your monitor, then identify the USB device that follows its KVM."
    var error: String?
    var status = "Checking service…"
    var running = false
    var installed = false
    var configuredArguments: [String] = []
    let home = FileManager.default.homeDirectoryForCurrentUser
    var helper: String { Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/kvm-display-sync").path }
    var plist: URL { home.appendingPathComponent("Library/LaunchAgents/io.github.kvm-display-sync.plist") }
    var service: String { "gui/\(getuid())/io.github.kvm-display-sync" }

    func refresh() async {
        installed = FileManager.default.fileExists(atPath: plist.path)
        configuredArguments = []
        if installed, let data = try? Data(contentsOf: plist),
           let value = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
           let args = value["ProgramArguments"] as? [String], args.count >= 2 {
            configuredArguments = Array(args.dropFirst(2))
        }
        running = (try? await Command.run("/bin/launchctl", ["print", service]))?.contains("state = running") == true
        if installed {
            do { status = try await Command.run(helper, ["status"] + configuredArguments) }
            catch { self.error = error.localizedDescription }
        } else { status = "Setup required. The display service has not been enabled." }
    }

    func poll() async {
        while !Task.isCancelled {
            if !busy { await refresh() }
            do { try await Task.sleep(for: .seconds(10)) } catch { return }
        }
    }

    func perform(_ operation: @escaping @MainActor () async throws -> Void) {
        guard !busy else { return }
        busy = true
        error = nil
        Task {
            defer { busy = false }
            do { try await operation(); await refresh() }
            catch { self.error = error.localizedDescription; await refresh() }
        }
    }

    func scan() async throws -> [USBDevice] {
        Array(Set(HardwareInventory.usbDevices())).sorted { $0.title < $1.title }
    }

    func captureBaseline() {
        perform {
            self.refreshDisplays()
            guard self.monitors.contains(where: { $0.id == self.selectedMonitor }) else { throw self.problem("Connect and select your KVM monitor first.") }
            self.baseline = try await self.scan()
            self.devices = self.baseline
            self.stage = 1
            self.message = "Switch the KVM to the other computer. Use the Mac’s built-in screen and keyboard, then click Compare USB devices."
        }
    }

    func compare() {
        perform {
            let now = try await self.scan()
            self.devices = self.baseline.filter { !now.contains($0) }
            guard !self.devices.isEmpty else { throw self.problem("No USB device disappeared. Check the monitor’s USB/KVM routing, wait a moment, and compare again.") }
            self.selectedUSB = self.devices.first(where: { $0.name.lowercased().contains("hub") })?.id ?? self.devices[0].id
            self.stage = 2
            self.message = "Select a device built into the monitor (usually a hub), then switch the KVM back to this Mac. Click Enable automatic sync once it returns."
        }
    }

    func enable() {
        perform {
            guard let display = self.monitors.first(where: { $0.id == self.selectedMonitor }),
                  let device = self.devices.first(where: { $0.id == self.selectedUSB }) else { throw self.problem("Select a monitor and USB device.") }
            let current = try await self.scan()
            guard current.contains(device) else { throw self.problem("The selected USB device has not returned. Switch the monitor back to this Mac, wait a moment, and try again.") }
            guard NSScreen.screens.contains(where: { screen in
                guard let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else { return false }
                return CGDisplayIsBuiltin(id.uint32Value) != 0
            }) else { throw self.problem("Mirror mode needs the Mac’s built-in screen. Open the lid before enabling sync.") }
            _ = try await Command.run(self.helper, ["install", "--usb-vendor", String(device.vendor), "--usb-product", String(device.product),
                "--display-vendor", String(display.vendor), "--display-model", String(display.model), "--display-serial", String(display.serial), "--display-name", display.name, "--actuator", "mirror"])
            self.stage = 3
            self.message = "Automatic sync is enabled and starts at login. The service continues when you quit this app."
        }
    }

    func toggle() {
        perform {
            _ = try await Command.run(self.helper, [self.running ? "pause" : "resume"])
        }
    }
    func remove() {
        perform { _ = try await Command.run(self.helper, ["uninstall"]); self.stage = 0 }
    }
    func restartSetup() { stage = 0; message = "Choose your monitor, then identify the USB device that follows its KVM." }
    func refreshDisplays() {
        monitors = HardwareInventory.monitors().filter { !$0.isBuiltin }
        if !monitors.contains(where: { $0.id == selectedMonitor }) { selectedMonitor = monitors.first?.id ?? 0 }
    }
    func logs() { NSWorkspace.shared.open(home.appendingPathComponent("Library/Logs/kvm-display-sync.log")) }
    func problem(_ text: String) -> NSError { NSError(domain: "KVM", code: 1, userInfo: [NSLocalizedDescriptionKey: text]) }
}

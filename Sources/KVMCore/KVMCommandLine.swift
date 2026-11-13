import Foundation

public enum KVMCommandLine {
    public static func run(_ arguments: [String]) {


        do {
            let (command, positional, opts) = try parse(arguments)
            Log.verbose = opts.verbose
        
            switch command {
            case "help":
                print(usage)
        
            case "watch":
                let actuator = try makeActuator(opts)
                let daemon = Daemon(vendor: opts.usbVendor, product: opts.usbProduct, actuator: actuator,
                                    debounce: opts.debounce, connectDebounce: opts.connectDebounce,
                                    reconcileInterval: opts.reconcileInterval, initialSync: opts.initialSync)
                try daemon.run()
        
            case "status":
                printStatus(opts)

            case "pause":
                try LaunchAgent.pause()

            case "resume":
                try LaunchAgent.resume()
        
            case "displays":
                for d in Displays.online() { print(d.summary) }
        
            case "usb":
                for d in USBWatcher.listAll().sorted(by: { $0.name < $1.name }) {
                    print(String(format: "0x%04X:0x%04X  %@", d.vendor, d.product, d.name))
                }
        
            case "test":
                guard let which = positional.first, ["on", "off"].contains(which) else {
                    throw UsageError.message("usage: kvm-display-sync test on|off")
                }
                let actuator = try makeActuator(opts)
                if which == "off" { try actuator.disconnect() } else { try actuator.connect() }
        
            case "setup":
                try Setup.run(base: opts)
        
            case "install":
                _ = try makeActuator(opts) // validate before writing anything
                try LaunchAgent.install(watchArguments: opts.watchArguments)
        
            case "uninstall":
                try LaunchAgent.uninstall()
        
            default:
                throw UsageError.message("unknown command '\(command)'\n\n\(usage)")
            }
        } catch let e as UsageError {
            fflush(stdout)
            FileHandle.standardError.write(Data("error: \(e)\n".utf8))
            exit(2)
        } catch {
            fflush(stdout)
            FileHandle.standardError.write(Data("error: \(error)\n".utf8))
            exit(1)
        }

    }
}

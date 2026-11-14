import Foundation

enum LaunchAgent {
    static let label = "io.github.kvm-display-sync"

    static var plistPath: String {
        NSString(string: "~/Library/LaunchAgents/\(label).plist").expandingTildeInPath
    }

    static var installedBinaryPath: String {
        NSString(string: "~/.local/bin/kvm-display-sync").expandingTildeInPath
    }

    static var logPath: String {
        NSString(string: "~/Library/Logs/kvm-display-sync.log").expandingTildeInPath
    }

    /// Copies the running binary to ~/.local/bin, writes the plist with the given watch arguments,
    /// and bootstraps it into the user's launchd domain.
    static func install(watchArguments: [String]) throws {
        let fm = FileManager.default
        let source = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath().path
        let sourceResolved = (source as NSString).isAbsolutePath
            ? source
            : fm.currentDirectoryPath + "/" + source

        try fm.createDirectory(atPath: (installedBinaryPath as NSString).deletingLastPathComponent,
                               withIntermediateDirectories: true)
        try fm.createDirectory(atPath: (plistPath as NSString).deletingLastPathComponent,
                               withIntermediateDirectories: true)
        try fm.createDirectory(atPath: (logPath as NSString).deletingLastPathComponent,
                               withIntermediateDirectories: true)

        try unload()
        // Re-running install from the installed helper must not delete its own source.
        if sourceResolved != installedBinaryPath {
            let staging = installedBinaryPath + "." + UUID().uuidString
            defer { try? fm.removeItem(atPath: staging) }
            try fm.copyItem(atPath: sourceResolved, toPath: staging)
            guard rename(staging, installedBinaryPath) == 0 else {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }
        }
        Log.info("installed binary to \(installedBinaryPath)")

        let plist: [String: Any] = [
            "Label": label,
            "ProgramArguments": [installedBinaryPath, "watch"] + watchArguments,
            "RunAtLoad": true,
            "KeepAlive": true,
            "ProcessType": "Interactive",
            "StandardOutPath": logPath,
            "StandardErrorPath": logPath,
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: URL(fileURLWithPath: plistPath), options: .atomic)
        Log.info("wrote \(plistPath)")

        // Retry briefly while launchd finishes deregistering the old job.
        var lastError: Error?
        for attempt in 1...5 {
            do {
                _ = try ProcessOutput.capture("/bin/launchctl", ["bootstrap", "gui/\(getuid())", plistPath], timeout: 10)
                lastError = nil
                break
            } catch {
                lastError = error
                Log.debug("bootstrap attempt \(attempt) failed: \(error)")
                Thread.sleep(forTimeInterval: 1)
            }
        }
        if let lastError { throw lastError }
        Log.info("loaded launch agent \(label); log at \(logPath)")
    }

    /// Unloads the agent if present and waits for its process to go away.
    private static func unload() throws {
        let service = "gui/\(getuid())/\(label)"
        let snapshot = try? ProcessOutput.capture("/bin/launchctl", ["print", service], timeout: 5)
        let pid = snapshot?.split(separator: "\n").compactMap { line -> Int32? in
            let fields = line.split(whereSeparator: { $0.isWhitespace })
            return fields.count == 3 && fields[0] == "pid" && fields[1] == "=" ? Int32(fields[2]) : nil
        }.first
        _ = try? ProcessOutput.capture("/bin/launchctl", ["bootout", service], timeout: 10)
        guard let pid else { return }
        // bootout can return before the daemon has finished restoring the layout.
        let deadline = Date().addingTimeInterval(10)
        while kill(pid, 0) == 0 && Date() < deadline { Thread.sleep(forTimeInterval: 0.1) }
        guard kill(pid, 0) != 0 else {
            throw UsageError.message("The previous service is still restoring the display. Try again in a moment.")
        }
    }

    static func uninstall() throws {
        try unload()
        let fm = FileManager.default
        if fm.fileExists(atPath: plistPath) {
            try fm.removeItem(atPath: plistPath)
            Log.info("removed \(plistPath)")
        }
        if fm.fileExists(atPath: installedBinaryPath) {
            try fm.removeItem(atPath: installedBinaryPath)
            Log.info("removed \(installedBinaryPath)")
        }
        Log.info("unloaded launch agent \(label)")
    }

    static func pause() throws { try unload() }

    static func resume() throws {
        guard FileManager.default.fileExists(atPath: plistPath) else {
            throw UsageError.message("No service configuration exists. Run setup first.")
        }
        let service = "gui/\(getuid())/\(label)"
        if (try? ProcessOutput.capture("/bin/launchctl", ["print", service], timeout: 5)) != nil {
            _ = try ProcessOutput.capture("/bin/launchctl", ["kickstart", service], timeout: 10)
        } else {
            _ = try ProcessOutput.capture("/bin/launchctl", ["bootstrap", "gui/\(getuid())", plistPath], timeout: 10)
        }
    }
}

import Foundation

enum ProcessOutput {
    /// File-backed output avoids pipe-buffer deadlocks and cross-thread mutable state.
    static func capture(_ executable: String, _ arguments: [String], timeout: TimeInterval) throws -> String {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: url.path, contents: nil)
        let output = try FileHandle(forWritingTo: url)
        defer { try? output.close(); try? FileManager.default.removeItem(at: url) }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = output
        process.standardError = output
        try process.run()
        defer { if process.isRunning { process.terminate() } }
        let deadline = Date().addingTimeInterval(timeout)
        while process.isRunning && Date() < deadline { Thread.sleep(forTimeInterval: 0.05) }
        guard !process.isRunning else {
            throw ActuatorError.commandFailed(executable, -1, "timed out after \(Int(timeout))s")
        }
        let text = String(decoding: try Data(contentsOf: url), as: UTF8.self)
        guard process.terminationStatus == 0 else {
            throw ActuatorError.commandFailed(executable, process.terminationStatus, text)
        }
        return text
    }
}

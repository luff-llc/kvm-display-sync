import Foundation

enum Command {
    @concurrent static func run(_ executable: String, _ arguments: [String]) async throws -> String {
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
        let deadline = Date().addingTimeInterval(25)
        while process.isRunning && Date() < deadline { try await Task.sleep(for: .milliseconds(50)) }
        if process.isRunning {
            process.terminate()
            throw NSError(domain: "KVM", code: 1, userInfo: [NSLocalizedDescriptionKey: "The command timed out. Please check the service log."])
        }
        let text = String(decoding: try Data(contentsOf: url), as: UTF8.self)
        guard process.terminationStatus == 0 else {
            throw NSError(domain: "KVM", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: text.isEmpty ? "Command failed (\(process.terminationStatus))." : text])
        }
        return text
    }
}

import Foundation

/// Stable hardware identity shared by the app and command-line engine.
public struct Monitor: Identifiable, Hashable, Codable, Sendable {
    public let id: UInt32
    public let vendor: UInt32
    public let model: UInt32
    public let serial: UInt32
    public let name: String
    public let isBuiltin: Bool
}

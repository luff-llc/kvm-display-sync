import Foundation

public struct USBDevice: Identifiable, Hashable, Codable, Sendable {
    public let vendor: Int
    public let product: Int
    public let name: String
    public var id: String { String(format: "0x%04X:0x%04X", vendor, product) }
    public var title: String { "\(name) · \(id)" }
    public init(vendor: Int, product: Int, name: String) {
        self.vendor = vendor; self.product = product; self.name = name
    }
}

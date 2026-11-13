import Foundation

func parseUInt32(_ text: String, flag: String) throws -> UInt32 {
    let value = try parseInt(text, flag: flag)
    guard let result = UInt32(exactly: value) else {
        throw UsageError.message("\(flag): expected an unsigned 32-bit integer")
    }
    return result
}

func parseUSBID(_ text: String, flag: String) throws -> Int {
    let value = try parseInt(text, flag: flag)
    guard (0...65535).contains(value) else {
        throw UsageError.message("\(flag): expected a USB ID from 0 to 65535")
    }
    return value
}

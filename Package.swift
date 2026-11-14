// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "kvm-display-sync",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "KVMCore", targets: ["KVMCore"]),
        .executable(name: "kvm-display-sync", targets: ["kvm-display-sync"]),
        .executable(name: "KVMDisplaySync", targets: ["KVMSyncApp"]),
    ],
    dependencies: [.package(path: "Vendor/Typecase")],
    targets: [
        .target(name: "KVMCore", swiftSettings: [.swiftLanguageMode(.v5)],
                linkerSettings: [.linkedFramework("IOKit"), .linkedFramework("CoreGraphics"), .linkedFramework("AppKit")]),
        .executableTarget(name: "kvm-display-sync", dependencies: ["KVMCore"], swiftSettings: [.swiftLanguageMode(.v5)]),
        .executableTarget(name: "KVMSyncApp", dependencies: ["KVMCore", .product(name: "Typecase", package: "Typecase")],
                          swiftSettings: [.swiftLanguageMode(.v6), .defaultIsolation(MainActor.self)],
                          linkerSettings: [.linkedFramework("SwiftUI")]),
        .testTarget(name: "KVMCoreTests", dependencies: ["KVMCore"], swiftSettings: [.swiftLanguageMode(.v5)]),
    ]
)

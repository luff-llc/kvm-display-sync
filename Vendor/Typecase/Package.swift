// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "Typecase", platforms: [.macOS(.v14)],
  products: [.library(name: "Typecase", targets: ["Typecase"])],
  targets: [.target(name: "Typecase", swiftSettings: [.swiftLanguageMode(.v6)])])

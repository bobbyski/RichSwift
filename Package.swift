// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RichSwift",
    products: [
        .library(
            name: "RichSwift",
            targets: ["RichSwift"]
        ),
        .executable(
            name: "richswift-demo",
            targets: ["RichSwiftDemo"]
        ),
    ],
    targets: [
        .target(
            name: "RichSwift"
        ),
        .executableTarget(
            name: "RichSwiftDemo",
            dependencies: ["RichSwift"]
        ),
        .testTarget(
            name: "RichSwiftTests",
            dependencies: ["RichSwift"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

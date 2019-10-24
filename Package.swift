// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Necom",
    platforms: [
        .macOS(.v10_10), .iOS(.v9), .tvOS(.v10), .watchOS(.v3)
    ],
    products: [
        .library(
            name: "Necom",
            targets: ["Necom"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Necom",
            dependencies: []),
        .testTarget(
            name: "NecomTests",
            dependencies: ["Necom"]),
    ]
)

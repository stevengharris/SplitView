// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SplitView",
    platforms: [.macOS(.v12), .iOS(.v13), .macCatalyst(.v13)],
    products: [
        .library(
            name: "SplitView",
            targets: ["SplitView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SplitView",
            dependencies: []),
    ]
)

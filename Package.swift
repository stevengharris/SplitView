// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "SplitView",
    platforms: [.macOS(.v12), .iOS(.v15), .macCatalyst(.v15)],
    products: [
        .library(
            name: "SplitView",
            targets: ["SplitView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SplitView",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]),
        .testTarget(name: "SplitViewTests", dependencies: ["SplitView"]),
    ]
)

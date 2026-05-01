// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ChartKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "ChartKit",
            targets: ["ChartKit"]
        )
    ],
    targets: [
        .target(
            name: "ChartKit"
        ),
        .testTarget(
            name: "ChartKitTests",
            dependencies: ["ChartKit"]
        )
    ]
)

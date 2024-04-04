// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "NavigationGroup",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .macCatalyst(.v16),
        .tvOS(.v16),
        .visionOS(.v1),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "NavigationGroup",
            targets: ["NavigationGroup"]
        ),
    ],
    targets: [
        .target(name: "NavigationGroup"),
        .testTarget(
            name: "NavigationGroupTests",
            dependencies: ["NavigationGroup"]
        ),
    ]
)

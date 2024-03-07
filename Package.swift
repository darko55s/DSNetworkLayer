// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DSNetworkLayer",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DSNetworkLayer",
            targets: ["DSNetworkLayer"]),
    ],
    targets: [
        .target(
            name: "DSNetworkLayer"),
        .testTarget(
            name: "DSNetworkLayerTests",
            dependencies: ["DSNetworkLayer"]),
    ]
)

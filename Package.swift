// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkLayerDemo",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "NetworkLayerDemo",
            targets: ["NetworkLayerDemo"]),
    ],
    targets: [
        .target(
            name: "NetworkLayerDemo"),
        .testTarget(
            name: "NetworkLayerDemoTests",
            dependencies: ["NetworkLayerDemo"]),
    ]
)

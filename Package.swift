// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Async",
    products: [
        .library(
            name: "Async",
            targets: ["Async"]),
        .library(
            name: "AsyncKit",
            type: .static,
            targets: ["Async"]),
    ],
    targets: [
        .target(
            name: "Async",
            dependencies: []),
        .testTarget(
            name: "AsyncTests",
            dependencies: ["Async"]),
    ]
)

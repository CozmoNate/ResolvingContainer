// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ResolvingContainer",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .watchOS(.v3),
        .tvOS(.v10)
    ],
    products: [
        .library(name: "ResolvingContainer", targets: ["ResolvingContainer"])
    ],
    targets: [
        .target(name: "ResolvingContainer", dependencies: [], path: "ResolvingContainer"),
    ],
    swiftLanguageVersions: [ .v5 ]
)

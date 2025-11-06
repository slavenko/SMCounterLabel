// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SMCounterLabel",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "SMCounterLabel",
            targets: ["SMCounterLabel"]
        )
    ],
    targets: [
        .target(
            name: "SMCounterLabel",
            path: "Sources/SMCounterLabel"
        )
    ]
)

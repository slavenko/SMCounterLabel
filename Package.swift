// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SMCounterLabel",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SMCounterLabel", targets: ["SMCounterLabel"]),
    ],
    targets: [
        .target(
            name: "SMCounterLabel",
            path: "Sources/SMCounterLabel"
        ),
        .testTarget(
            name: "SMCounterLabelTests",
            dependencies: ["SMCounterLabel"],
            path: "Tests/SMCounterLabelTests"
        ),
    ]
)

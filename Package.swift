// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PPTXAnalyzer",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        // Executable CLI tool
        .executable(
            name: "pptx-analyzer",
            targets: ["PPTXAnalyzerCLI"]
        ),
        // Library for PPTX parsing functionality
        .library(
            name: "PPTXKit",
            targets: ["PPTXKit"]
        )
    ],
    dependencies: [
        // Swift Argument Parser for CLI
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        // ZIPFoundation for reading PPTX files (which are ZIP archives)
        .package(url: "https://github.com/weichsel/ZIPFoundation", from: "0.9.17")
    ],
    targets: [
        // Main CLI executable target
        .executableTarget(
            name: "PPTXAnalyzerCLI",
            dependencies: [
                "PPTXKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/PPTXAnalyzerCLI"
        ),
        // Core PPTX parsing library
        .target(
            name: "PPTXKit",
            dependencies: [
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ],
            path: "Sources/PPTXKit"
        ),
        // Test targets
        .testTarget(
            name: "PPTXKitTests",
            dependencies: ["PPTXKit"],
            path: "Tests/PPTXKitTests",
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "PPTXAnalyzerCLITests",
            dependencies: ["PPTXAnalyzerCLI"],
            path: "Tests/PPTXAnalyzerCLITests"
        )
    ]
)
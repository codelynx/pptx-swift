// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TestText",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(path: "..")
    ],
    targets: [
        .executableTarget(
            name: "TestText",
            dependencies: [
                .product(name: "PPTXKit", package: "pptx-swift")
            ],
            path: ".",
            sources: ["test_text_render.swift"]
        )
    ]
)
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
	name: "ContentExtraction",
	platforms: [
		.macOS(.v13)
	],
	dependencies: [
		.package(path: "../..")
	],
	targets: [
		.executableTarget(
			name: "ContentExtraction",
			dependencies: [
				.product(name: "PPTXKit", package: "PPTXKit")
			],
			path: "."
		)
	]
)
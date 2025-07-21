// swift-tools-version: 5.9
import PackageDescription

let package = Package(
	name: "BasicViewer",
	platforms: [
		.macOS(.v13),
		.iOS(.v16)
	],
	dependencies: [
		.package(path: "../..")
	],
	targets: [
		.executableTarget(
			name: "BasicViewer",
			dependencies: [
				.product(name: "PPTXKit", package: "PPTXKit")
			],
			path: "."
		)
	]
)
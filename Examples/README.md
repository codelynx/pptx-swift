# PPTXKit Examples

This directory contains simple example projects demonstrating how to use PPTXKit in your applications.

## Examples

### BasicViewer
A minimal SwiftUI application that demonstrates:
- Loading a PPTX file using file picker
- Displaying slides with PPTXPresentationView
- Basic navigation controls

To run:
```bash
cd BasicViewer
swift run
```

### CustomRendering
Demonstrates advanced rendering features:
- Custom slide rendering
- Exporting slides as images
- Custom styling and layouts

### ContentExtraction
Shows how to extract content from presentations:
- Reading slide text
- Extracting metadata
- Analyzing presentation structure

## Getting Started

Each example is a standalone Swift package that depends on PPTXKit. To run any example:

1. Navigate to the example directory
2. Run `swift build` to build
3. Run `swift run` to execute

For iOS examples, open the Package.swift in Xcode and run on a simulator or device.

## Creating Your Own Project

To use PPTXKit in your own project, add it as a dependency in your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/PPTXKit.git", from: "1.0.0")
]
```

Then import PPTXKit in your Swift files:

```swift
import PPTXKit
```
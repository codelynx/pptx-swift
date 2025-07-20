# PPTX Analyzer

A Swift command-line utility and library for parsing and analyzing PowerPoint (PPTX) files.

## Overview

PPTX Analyzer provides both a command-line interface and a Swift library (PPTXKit) to inspect and extract information from PowerPoint presentations without requiring Microsoft Office. It's built on the ECMA-376 Office Open XML standard.

## Features

- 📊 **Slide Counting** - Quick slide count extraction
- 📋 **Slide Listing** - List all slides with multiple output formats (text, JSON, table)
- 🔍 **Detailed Slide Info** - Extract text, shapes, and relationships from individual slides
- 📄 **Presentation Metadata** - Access title, author, creation date, and more
- 🚀 **Fast & Efficient** - On-demand parsing for optimal performance
- 🔧 **Dual Interface** - Use as CLI tool or Swift library

## Installation

### Building from Source

```bash
git clone https://github.com/yourusername/pptx-swift.git
cd pptx-swift
swift build -c release
```

### Installing the CLI Tool

```bash
sudo cp .build/release/pptx-analyzer /usr/local/bin/
```

### Using as a Swift Package

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/pptx-swift.git", from: "1.0.0")
]
```

## CLI Usage

### Commands

```bash
# Get slide count
pptx-analyzer count presentation.pptx

# List all slides
pptx-analyzer list presentation.pptx
pptx-analyzer list --format json presentation.pptx
pptx-analyzer list --format table --verbose presentation.pptx

# Get slide information
pptx-analyzer info --index 1 presentation.pptx
pptx-analyzer info --id slide5 presentation.pptx

# Get presentation summary
pptx-analyzer summary presentation.pptx
```

See [CLI Usage Guide](docs/CLI_USAGE.md) for detailed command documentation.

## Library Usage

```swift
import PPTXKit

// Open a PPTX file
let document = try PPTXDocument(filePath: "presentation.pptx")

// Get slide count
let count = try document.getSlideCount()

// Get all slides
let slides = try document.getSlides()
for slide in slides {
    print("\(slide.index): \(slide.title ?? "Untitled")")
}

// Get specific slide
if let slide = try document.getSlide(at: 1) {
    print("Text content:")
    for text in slide.textContent {
        print("- \(text)")
    }
}

// Get metadata
let metadata = try document.getMetadata()
print("Author: \(metadata.author ?? "Unknown")")
```

See [API Reference](docs/API_REFERENCE.md) for complete library documentation.

## Documentation

- [API Reference](docs/API_REFERENCE.md) - Complete PPTXKit library documentation
- [CLI Usage Guide](docs/CLI_USAGE.md) - Detailed command-line interface guide
- [Architecture](docs/ARCHITECTURE.md) - System design and implementation details
- [Development Guide](docs/DEVELOPMENT.md) - Contributing and development setup

## Project Structure

```
pptx-swift/
├── Sources/
│   ├── PPTXKit/           # Core parsing library
│   └── PPTXAnalyzerCLI/   # Command-line interface
├── Tests/                 # Unit and integration tests
├── docs/                  # Documentation
└── specifications/        # ECMA-376 reference files
```

## Requirements

- Swift 5.9 or later
- macOS 12.0 or later

## Dependencies

- [Swift Argument Parser](https://github.com/apple/swift-argument-parser) - CLI argument parsing
- [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) - ZIP archive handling

## Contributing

Contributions are welcome! Please see the [Development Guide](docs/DEVELOPMENT.md) for setup instructions and coding guidelines.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Based on the ECMA-376 Office Open XML specification
- Inspired by the need for lightweight PPTX analysis tools
- Built with Swift and ❤️
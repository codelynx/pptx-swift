# PPTXKit

A Swift library for displaying and navigating PowerPoint (PPTX) presentations in iOS and macOS applications, with a companion CLI tool for testing and analysis.

## Overview

PPTXKit is a powerful Swift library that enables native iOS and macOS applications to display, render, and navigate PowerPoint presentations without requiring Microsoft Office. Built on the ECMA-376 Office Open XML standard, it provides high-fidelity rendering of slides with support for text, shapes, images, and theme colors.

The project includes a command-line tool (`pptx-analyzer`) that's perfect for testing PPTXKit's capabilities and analyzing PPTX files during development.

## Why PPTXKit?

- **Native Performance** - Built with Swift for optimal performance on Apple platforms
- **No Dependencies on Office** - Display PowerPoint files without Microsoft Office installed
- **Easy Integration** - Simple API for adding PPTX viewing to your iOS/macOS apps
- **Full Rendering Support** - Accurately renders text, shapes, images, and theme colors
- **SwiftUI & UIKit/AppKit** - Works seamlessly with both UI frameworks

## Features

### Core Library (PPTXKit)
- 🎨 **High-Fidelity Rendering** - Accurate slide rendering with proper layout and styling
- 🖼️ **Image Support** - Full support for embedded images (PNG, JPEG, TIFF)
- 📱 **Native Views** - Render slides as native iOS/macOS views or export as images
- 🎯 **Navigation API** - Simple presentation management and slide navigation
- 🎨 **Theme Support** - Proper handling of PowerPoint theme colors and styles
- 🔤 **Text Rendering** - Accurate text positioning with font styles and formatting
- 🔷 **Shape Rendering** - Support for rectangles, ellipses, and custom shapes with fills/gradients
- 🚀 **Performance** - On-demand parsing and rendering for optimal performance

### CLI Tool (pptx-analyzer)
- 📊 **Slide Analysis** - Quick slide count and content extraction
- 📋 **Batch Processing** - Process multiple presentations programmatically
- 🔍 **Debugging** - Inspect slide structure and relationships
- 🖼️ **Export** - Render slides as PNG images for testing

## Installation

### Swift Package Manager

Add PPTXKit to your iOS or macOS project:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/pptx-swift.git", from: "1.0.0")
]
```

Then add `PPTXKit` to your target dependencies:

```swift
targets: [
    .target(
        name: "YourApp",
        dependencies: ["PPTXKit"]
    )
]
```

## Quick Start

### Basic SwiftUI App

```swift
import SwiftUI
import PPTXKit

struct ContentView: View {
    @StateObject private var manager = PPTXManager()
    
    var body: some View {
        VStack {
            if manager.isLoaded {
                PPTXPresentationView(manager: manager)
                    .navigationControlsVisible(true)
            } else {
                Button("Open Presentation") {
                    openPresentation()
                }
            }
        }
    }
    
    func openPresentation() {
        // For iOS: Use document picker
        // For macOS: Use NSOpenPanel
        if let url = selectPPTXFile() {
            try? manager.loadPresentation(from: url)
        }
    }
}
```

### Basic UIKit App

```swift
import UIKit
import PPTXKit

class ViewController: UIViewController {
    let manager = PPTXManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load presentation
        if let url = Bundle.main.url(forResource: "presentation", withExtension: "pptx") {
            try? manager.loadPresentation(from: url)
            
            // Create presentation view controller
            let presentationVC = PPTXPresentationViewController(manager: manager)
            
            // Add as child view controller
            addChild(presentationVC)
            view.addSubview(presentationVC.view)
            presentationVC.view.frame = view.bounds
            presentationVC.didMove(toParent: self)
        }
    }
}

```

## Advanced Usage

### Custom Slide Rendering

```swift
import PPTXKit
import SwiftUI

struct CustomSlideView: View {
    let document: PPTXDocument
    @State private var currentSlide = 1
    
    var body: some View {
        VStack {
            // Slide view with custom styling
            PPTXSlideViewUI(document: document, slideIndex: currentSlide)
                .renderingQuality(.high)
                .frame(width: 800, height: 600)
                .cornerRadius(10)
                .shadow(radius: 5)
            
            // Custom navigation
            HStack {
                Button("Previous") {
                    if currentSlide > 1 {
                        currentSlide -= 1
                    }
                }
                
                Text("Slide \(currentSlide) of \(try? document.getSlideCount() ?? 0)")
                
                Button("Next") {
                    if currentSlide < (try? document.getSlideCount() ?? 0) {
                        currentSlide += 1
                    }
                }
            }
        }
    }
}
```

### Export Slides as Images

```swift
import PPTXKit

// Export single slide
let document = try PPTXDocument(filePath: "presentation.pptx")
let slide = try document.getSlide(at: 1)

let renderer = SlideRenderer(
    context: RenderingContext(size: CGSize(width: 1920, height: 1080))
)
let image = try renderer.render(slide: slide!, archive: document.archive)

// Save as PNG
if let data = image.pngData() {
    try data.write(to: URL(fileURLWithPath: "slide1.png"))
}

// Export all slides
for i in 1...(try document.getSlideCount()) {
    if let slide = try document.getSlide(at: i) {
        let image = try renderer.render(slide: slide, archive: document.archive)
        // Save each slide...
    }
}
```

### Extracting Content

```swift
import PPTXKit

let document = try PPTXDocument(filePath: "presentation.pptx")

// Get presentation metadata
let metadata = try document.getMetadata()
print("Title: \(metadata.title ?? "Untitled")")
print("Author: \(metadata.author ?? "Unknown")")
print("Created: \(metadata.created ?? Date())")

// Extract text from all slides
let slides = try document.getSlides()
for slide in slides {
    print("\nSlide \(slide.index):")
    for text in slide.textContent {
        print("  - \(text)")
    }
}
```

## CLI Tool Usage

The included `pptx-analyzer` CLI tool is great for:
- Testing PPTXKit functionality during development
- Batch processing presentations
- Quick analysis and debugging

### Installation

```bash
git clone https://github.com/yourusername/pptx-swift.git
cd pptx-swift
swift build -c release
sudo cp .build/release/pptx-analyzer /usr/local/bin/
```

### Basic Commands

```bash
# Quick analysis
pptx-analyzer count presentation.pptx
pptx-analyzer list presentation.pptx

# Export slides for testing
pptx-analyzer render presentation.pptx --slide 1 --output slide1.png

# Get detailed information
pptx-analyzer info --index 1 presentation.pptx
pptx-analyzer summary presentation.pptx
```

See [CLI Usage Guide](docs/CLI_USAGE.md) for more details.

## Use Cases

PPTXKit is perfect for:

- **Educational Apps** - Display course materials and lectures without requiring PowerPoint
- **Business Apps** - View presentations in meeting apps, CRM systems, or document viewers
- **Kiosk/Display Systems** - Show presentations on digital signage or information displays
- **Document Management** - Preview PowerPoint files in document management systems
- **Presentation Tools** - Build custom presentation apps with unique features
- **Content Processing** - Extract and analyze presentation content programmatically

## Sample Applications

Complete sample apps demonstrate real-world usage:

- **iOS Viewer** (`SampleApps/PPTXViewer-iOS/`)
  - Document browser integration
  - Full presentation navigation
  - Gesture support (swipe between slides)
  - Share and export functionality

- **macOS Viewer** (`SampleApps/PPTXViewer-macOS/`)
  - Split view with slide thumbnails
  - Keyboard navigation
  - Full-screen presentation mode
  - Quick Look integration

See [Sample Apps README](SampleApps/README.md) for setup instructions.

## Documentation

- [API Reference](docs/API_REFERENCE.md) - Complete PPTXKit library documentation
- [CLI Usage Guide](docs/CLI_USAGE.md) - Detailed command-line interface guide
- [Architecture](docs/ARCHITECTURE.md) - System design and implementation details
- [Development Guide](docs/DEVELOPMENT.md) - Contributing and development setup

## Architecture

PPTXKit is designed with a modular architecture:

```
PPTXKit/
├── Core/
│   ├── PPTXDocument        # Main document interface
│   ├── SlideXMLParser      # Advanced XML parsing with layout support
│   └── Parsers/            # Various XML parsers for PPTX structure
├── Rendering/
│   ├── SlideRenderer       # Core rendering engine
│   ├── ImageRenderer       # Image loading and rendering
│   └── ShapeRenderer       # Shape and geometry rendering
├── Platform/
│   ├── PPTXSlideView       # Native UIKit/AppKit view
│   ├── PPTXSlideViewUI     # SwiftUI wrapper
│   └── PPTXManager         # Presentation state management
└── Models/
    ├── Slide               # Slide data model
    ├── Shape               # Shape definitions
    └── Theme               # Theme color support
```

## Requirements

- Swift 5.9 or later
- macOS 13.0+ or iOS 16.0+
- Xcode 15.0+ (for development)

## Dependencies

- [Swift Argument Parser](https://github.com/apple/swift-argument-parser) - CLI argument parsing
- [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) - ZIP archive handling

## Contributing

We welcome contributions! PPTXKit is an active project with opportunities for:

- Additional shape type support
- Animation and transition rendering
- Performance optimizations
- Platform-specific features
- Documentation improvements

See the [Development Guide](docs/DEVELOPMENT.md) for setup instructions and coding guidelines.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built on the ECMA-376 Office Open XML specification
- Designed for the Apple developer community
- Created to enable PowerPoint viewing without Microsoft Office dependencies
- Special thanks to all contributors and users who have helped improve PPTXKit
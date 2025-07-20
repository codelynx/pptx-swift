# PPTXKit API Reference

## Overview

PPTXKit is a Swift library for parsing, analyzing, and rendering PowerPoint (PPTX) files. It provides a programmatic interface to extract information from PPTX files and render slides as native views or images without requiring Microsoft Office.

## Core Classes

### PPTXDocument

The main class for working with PPTX files.

#### Initialization

```swift
public init(filePath: String) throws
```

Creates a new PPTXDocument instance from a file path.

**Parameters:**
- `filePath`: Path to the PPTX file

**Throws:**
- `PPTXError.fileNotFound`: If the file doesn't exist
- `PPTXError.invalidPPTXFile`: If the file is not a valid PPTX
- `PPTXError.corruptedArchive`: If the ZIP archive is corrupted
- `PPTXError.missingRequiredFile`: If required PPTX structure files are missing

#### Methods

##### getSlideCount()

```swift
public func getSlideCount() throws -> Int
```

Returns the total number of slides in the presentation.

**Returns:** The number of slides

**Throws:** `PPTXError` if parsing fails

##### getSlides()

```swift
public func getSlides() throws -> [Slide]
```

Returns an array of all slides in the presentation.

**Returns:** Array of `Slide` objects

**Throws:** `PPTXError` if parsing fails

##### getSlide(at:)

```swift
public func getSlide(at index: Int) throws -> Slide?
```

Returns a specific slide by its 1-based index.

**Parameters:**
- `index`: 1-based index of the slide

**Returns:** `Slide` object or nil if index is out of bounds

**Throws:** `PPTXError` if parsing fails

##### getSlide(withId:)

```swift
public func getSlide(withId id: String) throws -> Slide?
```

Returns a specific slide by its ID.

**Parameters:**
- `id`: Slide ID (e.g., "slide1", "slide2")

**Returns:** `Slide` object or nil if not found

**Throws:** `PPTXError` if parsing fails

##### getMetadata()

```swift
public func getMetadata() throws -> PresentationMetadata
```

Returns metadata about the presentation.

**Returns:** `PresentationMetadata` object

**Throws:** `PPTXError` if parsing fails

### PPTXError

Error types that can be thrown by PPTXKit.

```swift
public enum PPTXError: Error, LocalizedError {
    case fileNotFound
    case invalidPPTXFile
    case corruptedArchive
    case missingRequiredFile(String)
    case invalidXML(String)
}
```

## Data Models

### Slide

Represents a single slide in a presentation.

```swift
public struct Slide {
    public let id: String                      // Slide ID (e.g., "slide1")
    public let index: Int                      // 1-based index
    public let layoutType: String?             // Layout type name
    public let title: String?                  // Slide title
    public let shapeCount: Int                 // Number of shapes
    public let notes: String?                  // Slide notes
    public let relationships: [Relationship]   // Related resources
    public let textContent: [String]           // Extracted text
}
```

### Relationship

Represents a relationship to another resource (image, chart, etc.).

```swift
public struct Relationship {
    public let id: String
    public let type: RelationshipType
    public let target: String
}

public enum RelationshipType {
    case image
    case chart
    case diagram
    case media
    case other(String)
}
```

### PresentationMetadata

Contains metadata about the presentation.

```swift
public struct PresentationMetadata {
    public let title: String?
    public let author: String?
    public let created: Date?
    public let modified: Date?
    public let company: String?
    public let slideCount: Int
    public let masterCount: Int
    public let layoutsUsed: Set<String>
    public let mediaCount: Int
    public let application: String?
    public let appVersion: String?
}
```

## Usage Examples

### Basic Usage

```swift
import PPTXKit

// Open a PPTX file
let document = try PPTXDocument(filePath: "presentation.pptx")

// Get slide count
let count = try document.getSlideCount()
print("Total slides: \(count)")

// List all slides
let slides = try document.getSlides()
for slide in slides {
    print("\(slide.index): \(slide.id)")
    if let title = slide.title {
        print("  Title: \(title)")
    }
}

// Get specific slide
if let slide = try document.getSlide(at: 1) {
    print("First slide content:")
    for text in slide.textContent {
        print("- \(text)")
    }
}

// Get metadata
let metadata = try document.getMetadata()
print("Title: \(metadata.title ?? "Untitled")")
print("Author: \(metadata.author ?? "Unknown")")
```

### Error Handling

```swift
do {
    let document = try PPTXDocument(filePath: "presentation.pptx")
    // Use document...
} catch PPTXDocument.PPTXError.fileNotFound {
    print("File not found")
} catch PPTXDocument.PPTXError.invalidPPTXFile {
    print("Invalid PPTX file")
} catch {
    print("Error: \(error)")
}
```

## Thread Safety

PPTXKit is not thread-safe. Each `PPTXDocument` instance should be used from a single thread.

## Memory Considerations

- PPTX files are loaded into memory as needed
- Large presentations may consume significant memory
- Slide content is parsed on-demand when accessing individual slides

## Presentation Management API

### PPTXManager

A high-level manager for PPTX presentations providing navigation and state management.

#### Properties

```swift
public private(set) var currentSlideIndex: Int    // Current slide (1-based)
public private(set) var slideCount: Int           // Total slides
public private(set) var metadata: PresentationMetadata?  // Presentation metadata
public private(set) var isLoading: Bool          // Loading state
public private(set) var error: Error?            // Last error
public var currentSlide: Slide?                  // Current slide
public var canGoPrevious: Bool                   // Can navigate back
public var canGoNext: Bool                       // Can navigate forward
public var progress: Double                      // Progress (0.0-1.0)
public weak var delegate: PPTXManagerDelegate?   // Navigation delegate
```

#### Methods

```swift
// Loading
public func loadPresentation(from filePath: String) throws

// Navigation
public func goToPrevious() -> Bool
public func goToNext() -> Bool
public func goToSlide(at index: Int) -> Bool
public func goToSlide(withId slideId: String) -> Bool
public func goToFirst() -> Bool
public func goToLast() -> Bool

// Slide access
public func slide(at index: Int) -> Slide?
public func slide(withId slideId: String) -> Slide?
public func allSlides() -> [Slide]

// Search
public func searchSlides(containing text: String) -> [Slide]

// View creation
public func createSlideView(frame: CGRect = .zero) -> PPTXSlideView?
```

### PPTXPresentationView

A complete SwiftUI presentation view with navigation controls.

```swift
PPTXPresentationView(manager: manager)
    .navigationControlsVisible(true)
    .slideCounterVisible(true)
    .progressBarVisible(true)
    .renderingQuality(.high)
    .backgroundColor(.black)
    .onSlideChange { index in
        print("Moved to slide \(index)")
    }
```

### PPTXThumbnailGridView

A SwiftUI grid view showing all slides as thumbnails.

```swift
PPTXThumbnailGridView(manager: manager)
```

### PPTXPresentationViewController

A UIViewController for presenting slides (iOS).

```swift
let manager = PPTXManager()
let viewController = PPTXPresentationViewController(manager: manager)
viewController.showNavigationControls = true
viewController.renderingQuality = .high
```

### PPTXManagerDelegate

Protocol for receiving navigation events.

```swift
public protocol PPTXManagerDelegate: AnyObject {
    func pptxManager(_ manager: PPTXManager, didLoadPresentationWithSlideCount count: Int)
    func pptxManager(_ manager: PPTXManager, didNavigateFrom oldIndex: Int, to newIndex: Int)
    func pptxManager(_ manager: PPTXManager, didEncounterError error: Error)
}
```

## Rendering API

### PPTXSlideView

A platform-specific view for rendering PPTX slides (UIView on iOS, NSView on macOS).

#### Initialization

```swift
// With slide
public init(slide: Slide, frame: CGRect)

// With document and index
public init(document: PPTXDocument, slideIndex: Int, frame: CGRect = .zero)

// With document and ID
public init(document: PPTXDocument, slideId: String, frame: CGRect = .zero)
```

#### Properties

```swift
public var renderingScale: CGFloat      // Rendering scale factor
public var renderingQuality: RenderingQuality  // Rendering quality setting
```

### PPTXSlideViewUI

SwiftUI view for rendering PPTX slides.

```swift
// Initialize with slide
PPTXSlideViewUI(slide: slide)

// Initialize with document and index
PPTXSlideViewUI(document: document, slideIndex: 1)

// Configure rendering
PPTXSlideViewUI(document: document, slideIndex: 1)
    .renderingQuality(.high)
    .renderingScale(2.0)
    .frame(width: 800, height: 600)
```

### SlideRenderer

Core rendering engine for converting slides to images.

```swift
public class SlideRenderer {
    public init(context: RenderingContext)
    public func render(slide: Slide) throws -> CGImage
}
```

### RenderingContext

Configuration for slide rendering.

```swift
public class RenderingContext {
    public init(
        size: CGSize,
        scale: CGFloat = 1.0,
        quality: RenderingQuality = .balanced
    )
    
    public func emuToPoints(_ emu: Int) -> CGFloat
    public func emuToPixels(_ emu: Int) -> CGFloat
}
```

### RenderingQuality

Quality settings for rendering.

```swift
public enum RenderingQuality {
    case low       // Fast rendering, minimal effects
    case balanced  // Good quality/performance balance
    case high      // Best quality, all effects
}
```

## Presentation Management Examples

### Basic Navigation

```swift
import PPTXKit

// Create and load presentation
let manager = PPTXManager()
try manager.loadPresentation(from: "presentation.pptx")

// Navigate
manager.goToNext()
manager.goToPrevious()
manager.goToSlide(at: 5)
manager.goToFirst()
manager.goToLast()

// Check state
print("Current slide: \(manager.currentSlideIndex) of \(manager.slideCount)")
print("Progress: \(manager.progress * 100)%")
```

### SwiftUI Integration

```swift
import SwiftUI
import PPTXKit

struct PresentationView: View {
    @StateObject private var manager = PPTXManager()
    
    var body: some View {
        PPTXPresentationView(manager: manager)
            .navigationControlsVisible(true)
            .renderingQuality(.high)
            .onSlideChange { index in
                print("Now showing slide \(index)")
            }
            .onAppear {
                try? manager.loadPresentation(from: "presentation.pptx")
            }
    }
}
```

### UIKit Integration

```swift
import UIKit
import PPTXKit

class ViewController: UIViewController {
    let manager = PPTXManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create presentation view controller
        let presentationVC = PPTXPresentationViewController(manager: manager)
        
        // Add as child
        addChild(presentationVC)
        view.addSubview(presentationVC.view)
        presentationVC.view.frame = view.bounds
        presentationVC.didMove(toParent: self)
        
        // Load presentation
        try? manager.loadPresentation(from: "presentation.pptx")
    }
}
```

### Search and Navigation

```swift
// Search for slides
let results = manager.searchSlides(containing: "revenue")
for slide in results {
    print("Found in slide \(slide.index): \(slide.title ?? "")")
}

// Navigate to first result
if let firstResult = results.first {
    manager.goToSlide(withId: firstResult.id)
}
```

### Delegate Pattern

```swift
class PresentationController: PPTXManagerDelegate {
    let manager = PPTXManager()
    
    init() {
        manager.delegate = self
    }
    
    func pptxManager(_ manager: PPTXManager, didLoadPresentationWithSlideCount count: Int) {
        print("Loaded presentation with \(count) slides")
    }
    
    func pptxManager(_ manager: PPTXManager, didNavigateFrom oldIndex: Int, to newIndex: Int) {
        print("Navigated from slide \(oldIndex) to \(newIndex)")
    }
    
    func pptxManager(_ manager: PPTXManager, didEncounterError error: Error) {
        print("Error: \(error)")
    }
}
```

## Rendering Examples

### SwiftUI Integration

```swift
import SwiftUI
import PPTXKit

struct SlideView: View {
    let document: PPTXDocument
    @State private var slideIndex = 1
    
    var body: some View {
        VStack {
            PPTXSlideViewUI(document: document, slideIndex: slideIndex)
                .renderingQuality(.high)
                .frame(height: 600)
            
            HStack {
                Button("Previous") {
                    if slideIndex > 1 { slideIndex -= 1 }
                }
                Text("Slide \(slideIndex)")
                Button("Next") {
                    if slideIndex < (try? document.getSlideCount()) ?? 0 {
                        slideIndex += 1
                    }
                }
            }
        }
    }
}
```

### UIKit/AppKit Integration

```swift
// iOS
let slideView = PPTXSlideView(document: document, slideIndex: 1)
slideView.renderingQuality = .high
slideView.frame = view.bounds
view.addSubview(slideView)

// macOS
let slideView = PPTXSlideView(document: document, slideIndex: 1)
slideView.renderingQuality = .high
slideView.frame = view.bounds
view.addSubview(slideView)
```

### Image Export

```swift
// Render slide to image
let context = RenderingContext(
    size: CGSize(width: 1920, height: 1080),
    scale: 2.0,
    quality: .high
)
let renderer = SlideRenderer(context: context)
let image = try renderer.render(slide: slide)

// Save to file (iOS)
if let uiImage = UIImage(cgImage: image) {
    let data = uiImage.pngData()
    try data?.write(to: outputURL)
}

// Save to file (macOS)
let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
if let tiffData = nsImage.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    try pngData.write(to: outputURL)
}
```

## Limitations

- Read-only access (no modification support)
- Limited layout type detection
- Notes parsing not fully implemented
- No support for animations or transitions
- Media files are detected but not extracted
- Rendering currently shows placeholder content (full XML parsing in development)
- Complex shapes and effects may not render accurately
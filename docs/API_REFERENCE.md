# PPTXKit API Reference

## Overview

PPTXKit is a Swift library for parsing and analyzing PowerPoint (PPTX) files. It provides a programmatic interface to extract information from PPTX files without requiring Microsoft Office.

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

## Limitations

- Read-only access (no modification support)
- Limited layout type detection
- Notes parsing not fully implemented
- No support for animations or transitions
- Media files are detected but not extracted
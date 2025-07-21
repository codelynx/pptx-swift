# Image Rendering Implementation

This document describes the implementation of image rendering support in PPTXKit.

## Overview

Image rendering was added to enable PPTXKit to display embedded images (PNG, JPEG, TIFF) within PowerPoint slides. This feature required changes across multiple components to properly load images from the PPTX archive and render them with correct orientation.

## Key Components

### 1. ImageRenderer

A new class responsible for rendering images embedded in slides.

**Location**: `Sources/PPTXKit/Rendering/Elements/ImageRenderer.swift`

**Key Features**:
- Synchronous and asynchronous image loading from PPTX archives
- Support for relative path resolution (e.g., `../media/image1.png`)
- Coordinate system transformation to fix image orientation
- Image effect support (crop, grayscale, brightness)
- Aspect ratio preservation during rendering

### 2. SlideXMLParser Enhancements

The XML parser was enhanced to detect and parse picture elements.

**Key Additions**:
- `PictureInfo` struct to store image relationship IDs
- Picture element parsing in the XML delegate methods
- Support for `p:pic` elements and their `a:blip` children

### 3. Archive Access Chain

To load images, the PPTX archive must be accessible throughout the rendering chain:

```
PPTXDocument → PPTXSlideView → SlideRenderer → ImageRenderer
```

**Changes Made**:
- Made `PPTXDocument.archive` property accessible (internal(set))
- Updated `PPTXSlideView` to accept document parameter
- Modified `SlideRenderer` to accept and pass archive
- Updated all view creation code to pass document instead of just slide

## Implementation Details

### Path Resolution

Images in PPTX files often use relative paths. The implementation handles three cases:

1. **Relative paths with `../`**: Resolved relative to `ppt/` folder
   - Example: `../media/image1.png` → `ppt/media/image1.png`

2. **Absolute paths**: Leading `/` is removed
   - Example: `/media/image1.png` → `media/image1.png`

3. **Simple relative paths**: Resolved relative to `ppt/slides/`
   - Example: `image1.png` → `ppt/slides/image1.png`

### Coordinate System Fix

Images were rendering upside down due to Core Graphics coordinate system differences. The fix applies a transformation:

```swift
// Flip the coordinate system for the image
context.translateBy(x: 0, y: drawRect.origin.y + drawRect.height)
context.scaleBy(x: 1, y: -1)
context.translateBy(x: 0, y: -drawRect.origin.y)
```

### Error Handling

Comprehensive error handling was added:
- Missing archive errors
- Image not found errors
- Image loading failures
- Graceful fallback to placeholder text

## Usage

### Basic Usage

```swift
// Render slide with images
let document = try PPTXDocument(filePath: "presentation.pptx")
let slide = try document.getSlide(at: 1)!

let context = RenderingContext(size: CGSize(width: 1920, height: 1080))
let renderer = SlideRenderer(context: context)

// Pass archive for image loading
let image = try renderer.render(slide: slide, archive: document.archive)
```

### SwiftUI View

```swift
// Pass document instead of just slide
PPTXSlideViewUI(document: document, slideIndex: 1)
    .renderingQuality(.high)
```

### UIKit/AppKit View

```swift
// Initialize with document for image support
let slideView = PPTXSlideView(document: document, slideIndex: 1)
slideView.renderingQuality = .high
```

## Testing

The implementation includes comprehensive logging for debugging:
- `[PPTXDocument]` - Relationship loading
- `[SlideRenderer]` - Image processing in render tree
- `[ImageRenderer]` - Path resolution and loading
- `[PPTXSlideView]` - Archive availability

## Future Enhancements

Existing TODO items that could be addressed:
1. Pattern fill support in ShapeRenderer
2. Slide notes parsing
3. Layout type extraction from slide layouts
4. Image effects like filters and transformations
5. Support for linked (external) images

## Performance Considerations

- Images are loaded synchronously during rendering
- Large images may impact rendering performance
- Consider implementing image caching for repeated renders
- Archive is kept in memory while document is open
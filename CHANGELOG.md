# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Image rendering support for PPTX slides
  - Implemented `ImageRenderer` class for rendering images from slide relationships
  - Added synchronous and asynchronous image loading methods
  - Support for PNG, JPEG, and TIFF image formats
  - Proper path resolution for relative image paths (e.g., `../media/image1.png`)
  - Image aspect ratio preservation during rendering
- Advanced XML parsing with `SlideXMLParser`
  - Accurate text positioning and paragraph handling
  - Support for text runs with different formatting
  - Proper bullet point and numbering support
  - Picture element parsing for image detection
  - Style-based shape properties parsing for accurate shape rendering
- Shape rendering with background fills
  - Support for solid color fills and gradient fills
  - Proper shape geometry types (rect, roundRect, ellipse)
  - Stroke/border rendering support
  - Background shapes rendered behind text for proper layering
- CLI render command for exporting slides as images
  - Added `render` subcommand to pptx-analyzer CLI
  - Support for custom output dimensions and scaling
  - PNG format export with high quality rendering
- Comprehensive logging system for debugging
  - Added detailed logging in `SlideRenderer`, `ImageRenderer`, and `PPTXDocument`
  - Logs help identify issues with archive access and image loading

### Fixed
- Fixed "Diet & Nutrition" text splitting issue by implementing proper paragraph-aware XML parsing
- Fixed image orientation issue (images rendering upside down) by adding coordinate system transformation
- Fixed "No archive" error when switching slides in the macOS viewer
  - Updated `ContentView` to pass document instead of just slide
  - Fixed thumbnail view to use document for proper archive access
- Fixed Swift Package Manager case sensitivity issue (renamed 'sources' to 'Sources')
- Made `SlideXMLParser` class and methods public for proper visibility
- Fixed style-based fill colors not rendering (e.g., yellow background missing on text boxes)
  - Added support for parsing `<p:style>` elements with `<a:fillRef>` references
  - Implemented theme color mapping (accent1-6) to actual RGB values
  - Fixed issue where non-accent scheme colors were incorrectly resetting fill colors
- Fixed incorrect fill colors when shapes have both line and fill references
  - Added `isInFillRef` flag to track parsing context within style elements
  - Now correctly distinguishes between `<a:lnRef>` (line) and `<a:fillRef>` (fill) color references
- Fixed iOS rendering issue where slides appeared upside down
  - Applied coordinate system flip to both iOS and macOS platforms in `SlideRenderer`
  - Both UIKit and AppKit expect origin at top-left, while Core Graphics uses bottom-left
  - Fixed slide 11 rendering issue where green line color was incorrectly applied as fill color
  - Properly handles "lt1" (light 1) theme color as transparent/white fill

### Changed
- Converted code indentation from spaces to tabs throughout the project
- Enhanced `PPTXSlideView` to accept document parameter for archive access
- Updated `PPTXPresentationView` to pass document when creating slide views
- Improved error handling throughout the slide rendering pipeline

### Technical Details
- Image coordinate system fix applied in `ImageRenderer.renderImage()`:
  ```swift
  context.translateBy(x: 0, y: drawRect.origin.y + drawRect.height)
  context.scaleBy(x: 1, y: -1)
  context.translateBy(x: 0, y: -drawRect.origin.y)
  ```
- Archive is now properly passed through the rendering chain:
  - `PPTXDocument` → `PPTXSlideView` → `SlideRenderer` → `ImageRenderer`
- Style-based fill color parsing in `SlideXMLParser`:
  ```swift
  // Parse style fill references - only when inside fillRef
  if elementName == "a:fillRef" && isInShapeStyle {
      isInFillRef = true
  }
  
  if elementName == "a:schemeClr" && isInShapeStyle && isInFillRef {
      switch val {
      case "accent1": styleFillColor = "5B9BD5" // Blue
      case "accent4": styleFillColor = "FFC000" // Yellow
      case "accent6": styleFillColor = "70AD47" // Green
      case "lt1": styleFillColor = nil // Light 1 - white/transparent
      default: break // Don't reset for other scheme colors
      }
  }
  ```

## [1.0.0] - Previous Release

### Features
- Basic PPTX parsing and analysis
- Slide counting and listing
- Text content extraction
- Presentation metadata access
- Basic slide rendering without images
- CLI tool for PPTX analysis
- SwiftUI and UIKit/AppKit support
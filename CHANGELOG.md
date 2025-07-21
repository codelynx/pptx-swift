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

## [1.0.0] - Previous Release

### Features
- Basic PPTX parsing and analysis
- Slide counting and listing
- Text content extraction
- Presentation metadata access
- Basic slide rendering without images
- CLI tool for PPTX analysis
- SwiftUI and UIKit/AppKit support
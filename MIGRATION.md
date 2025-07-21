# PPTXKit Migration Guide

This guide helps you migrate from the previous project structure to the new PPTXKit-focused organization.

## Package Name Change

The package has been renamed from `PPTXAnalyzer` to `PPTXKit` to better reflect its primary purpose as a Swift library for rendering PowerPoint presentations.

**Before:**
```swift
.package(url: "...", from: "1.0.0") // Package name: PPTXAnalyzer
```

**After:**
```swift
.package(url: "...", from: "1.0.0") // Package name: PPTXKit
```

## Import Statements

No changes needed - you still import `PPTXKit`:
```swift
import PPTXKit
```

## Directory Structure Changes

The source code has been reorganized for better clarity:

### Core Components
- `PPTXDocument` → `Sources/PPTXKit/Core/Document/PPTXDocument.swift`
- Parser files → `Sources/PPTXKit/Core/Parsers/`
- Model files → `Sources/PPTXKit/Core/Models/`

### UI Components
- `PPTXPresentationView` → `Sources/PPTXKit/UI/SwiftUI/`
- `PPTXSlideView` → `Sources/PPTXKit/UI/UIKit/`
- `PPTXManager` → `Sources/PPTXKit/UI/Common/`

### Rendering
- Rendering components remain in `Sources/PPTXKit/Rendering/`

## Sample Apps Location

Sample applications have moved from `SampleApps/` to `Apps/`:
- `Apps/PPTXViewer-iOS/`
- `Apps/PPTXViewer-macOS/`

## New Examples

New simplified examples are available in the `Examples/` directory:
- `Examples/BasicViewer/` - Minimal viewer implementation
- `Examples/CustomRendering/` - Advanced rendering features
- `Examples/ContentExtraction/` - Text and metadata extraction

## API Changes

No API changes - all public interfaces remain the same.

## CLI Tool

The `pptx-analyzer` CLI tool is still available but is now positioned as a companion tool for testing and development rather than the primary product.
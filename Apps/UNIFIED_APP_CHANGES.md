# PPTXViewer Unified App Changes

## Overview
The PPTXViewer app has been restructured from separate iOS and macOS apps into a single unified codebase using SwiftUI's platform conditional compilation.

## Major Changes

### 1. Project Structure
- **Removed**: `Apps/PPTXViewer-iOS/` and `Apps/PPTXViewer-macOS/` directories
- **Created**: Single `Apps/PPTXViewer/` directory containing unified codebase
- **Platform-specific files**: Use `#if os(iOS)` and `#if os(macOS)` conditionals

### 2. Document-Based Architecture (macOS)
The macOS app now follows Apple's document-based app pattern:
- PPTX files are treated as documents that can be opened directly from Finder
- Supports File → Open menu command
- Each document opens in its own window
- No longer uses a file picker within the app window

### 3. New Files Created

#### PPTXDocumentWrapper.swift (macOS only)
- Implements `FileDocument` protocol for document-based app support
- Handles loading PPTX files from disk
- Manages temporary file creation for PPTXManager

#### DocumentView.swift (macOS only)
- Main document window view with NavigationSplitView
- Sidebar with:
  - View modes: Presentation, Thumbnails, Outline
  - Slide list with current slide indicator
- Detail area shows selected view mode

#### MacOSViews.swift (macOS only)
Contains macOS-specific view implementations:
- `PresentationMainView`: Full presentation mode with navigation controls
- `ThumbnailsMainView`: Grid view of slide thumbnails
- `OutlineMainView`: Searchable list view of slides
- `SlideRowView`: Individual slide row in outline view

### 4. Modified Files

#### PPTXViewerApp.swift
- Uses conditional compilation for platform-specific scenes
- iOS: `WindowGroup` with `ContentView`
- macOS: `DocumentGroup` with `PPTXDocumentWrapper`

#### ContentView.swift
- Now iOS-only (wrapped in `#if os(iOS)`)
- Removed all macOS-specific code
- Maintains original tab-based interface for iOS

#### Info.plist Files
- Split into platform-specific versions:
  - `Info-iOS.plist`: Standard iOS app configuration
  - `Info-macOS.plist`: Document type associations for PPTX files

### 5. Code Style Changes
- All Swift files converted from 4-space indentation to tabs
- Consistent with project's `.editorconfig` settings

## Platform-Specific Behaviors

### iOS
- Tab-based interface with Presentation, Thumbnails, and Info tabs
- File picker for opening PPTX files
- Touch-optimized navigation

### macOS
- Document-based app with native file handling
- Sidebar navigation with multiple view modes
- Keyboard shortcuts (arrow keys for navigation)
- Multi-window support

## Build Configuration
- Single Xcode project with two targets:
  - PPTXViewer (iOS)
  - PPTXViewer (macOS)
- Shared source files compiled conditionally
- Platform-specific deployment targets:
  - iOS 16.0+
  - macOS 13.0+

## Benefits
1. **Code Reuse**: Common logic shared between platforms
2. **Maintainability**: Single codebase to maintain
3. **Native Experience**: Each platform gets appropriate UI paradigms
4. **Consistency**: Shared business logic ensures feature parity

## Migration Notes
- Existing iOS functionality preserved
- macOS app now more Mac-like with document paradigm
- No breaking changes to PPTXKit library usage
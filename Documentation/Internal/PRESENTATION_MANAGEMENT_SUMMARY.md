# PPTXKit Presentation Management

## Overview

PPTXKit now includes a comprehensive presentation management system that provides high-level APIs for navigating and displaying PowerPoint presentations in iOS and macOS applications.

## Key Components

### 1. PPTXManager
A high-level manager class that handles:
- **Presentation Loading**: Load PPTX files and manage state
- **Navigation**: Navigate between slides with various methods
- **State Management**: Track current slide, progress, and metadata
- **Search**: Search slides by content
- **Delegate Pattern**: Notify about navigation and loading events

### 2. PPTXPresentationView (SwiftUI)
A complete presentation view with:
- **Navigation Controls**: Previous/Next buttons with keyboard shortcuts
- **Progress Bar**: Visual progress indicator
- **Slide Counter**: Current slide number display
- **Customizable UI**: Toggle controls, set quality, background color

### 3. PPTXPresentationViewController (UIKit)
A UIViewController for iOS apps featuring:
- **Native Navigation**: UIButtons and gesture support
- **Swipe Gestures**: Navigate with swipe left/right
- **Menu System**: Jump to any slide
- **Adaptive Layout**: Auto-layout constraints

### 4. PPTXThumbnailGridView / PPTXThumbnailViewController
Grid views for displaying all slides as thumbnails:
- **SwiftUI Grid**: Adaptive grid layout
- **UIKit Collection**: UICollectionView implementation
- **Selection Tracking**: Highlight current slide

## Usage Examples

### Basic Navigation
```swift
let manager = PPTXManager()
try manager.loadPresentation(from: "presentation.pptx")

// Navigate
manager.goToNext()
manager.goToSlide(at: 5)
print("Current: \(manager.currentSlideIndex) of \(manager.slideCount)")
```

### SwiftUI Integration
```swift
struct ContentView: View {
    @StateObject private var manager = PPTXManager()
    
    var body: some View {
        PPTXPresentationView(manager: manager)
            .navigationControlsVisible(true)
            .renderingQuality(.high)
    }
}
```

### UIKit Integration
```swift
let manager = PPTXManager()
let presentationVC = PPTXPresentationViewController(manager: manager)
present(presentationVC, animated: true)
```

## Features

### Navigation Methods
- `goToNext()` / `goToPrevious()` - Sequential navigation
- `goToSlide(at:)` - Jump to specific index
- `goToSlide(withId:)` - Navigate by slide ID
- `goToFirst()` / `goToLast()` - Jump to ends
- `execute(_ command:)` - Command pattern support

### State Properties
- `currentSlideIndex` - Current position (1-based)
- `slideCount` - Total number of slides
- `currentSlide` - Active slide object
- `progress` - Presentation progress (0.0-1.0)
- `canGoNext` / `canGoPrevious` - Navigation availability

### Delegate Callbacks
```swift
protocol PPTXManagerDelegate {
    func pptxManager(_ manager: PPTXManager, didLoadPresentationWithSlideCount count: Int)
    func pptxManager(_ manager: PPTXManager, didNavigateFrom oldIndex: Int, to newIndex: Int)
    func pptxManager(_ manager: PPTXManager, didEncounterError error: Error)
}
```

### Search Functionality
```swift
let results = manager.searchSlides(containing: "budget")
for slide in results {
    print("Found in slide \(slide.index): \(slide.title ?? "")")
}
```

## Customization

### PPTXPresentationView Modifiers
- `.navigationControlsVisible(_:)` - Show/hide controls
- `.slideCounterVisible(_:)` - Show/hide counter
- `.progressBarVisible(_:)` - Show/hide progress
- `.renderingQuality(_:)` - Set render quality
- `.backgroundColor(_:)` - Set background
- `.onSlideChange(_:)` - Navigation callback
- `.onError(_:)` - Error handling

### PPTXPresentationViewController Properties
- `showNavigationControls` - Toggle navigation bar
- `showProgressBar` - Toggle progress indicator
- `renderingQuality` - Rendering quality setting

## Benefits

1. **Easy Integration**: Drop-in views for SwiftUI and UIKit
2. **Full Navigation**: Complete slide navigation with gestures
3. **State Management**: Automatic state tracking and updates
4. **Customizable UI**: Flexible appearance options
5. **Cross-Platform**: Works on iOS and macOS
6. **Search Support**: Find slides by content
7. **Thumbnail Views**: Grid layouts for slide overview

## Architecture

The presentation management system is built on top of PPTXKit's core parsing and rendering capabilities:

```
PPTXManager (State & Navigation)
    ├── PPTXDocument (Parsing)
    └── PPTXSlideView (Rendering)
        └── SlideRenderer (Core Graphics)
```

This layered approach provides flexibility while maintaining clean separation of concerns.
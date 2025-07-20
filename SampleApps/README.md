# PPTX Viewer Sample Apps

This directory contains complete sample applications demonstrating how to use PPTXKit to build PowerPoint viewers for iOS and macOS.

## Quick Start

### Option 1: Use Generated Xcode Projects (Easiest)

```bash
# The project is already generated! Just open it:
cd SampleApps
open PPTXViewer.xcodeproj

# Or regenerate if needed:
swift generate_multiplatform_project.swift
open PPTXViewer.xcodeproj
```

Then in Xcode:
1. Wait for package dependencies to resolve
2. Select your development team
3. Build and run!

### Option 2: Create Your Own Project

Follow the [Quick Start Guide](QUICK_START.md) to create a new project from scratch in 2 minutes.

## Sample Apps

### PPTXViewer-iOS
A complete iOS app that demonstrates:
- Opening PPTX files using document picker
- Viewing slides in presentation mode
- Thumbnail grid view
- Navigation controls with gestures
- Presentation info display

### PPTXViewer-macOS
A full-featured macOS app showcasing:
- Native macOS document handling
- Split view with sidebar navigation
- Multiple view modes (Presentation, Thumbnails, Outline)
- Keyboard shortcuts
- Search functionality

## Requirements

- Xcode 15.0 or later
- iOS 14.0+ (for iOS app)
- macOS 12.0+ (for macOS app)
- Swift 5.9+

## Setup Instructions

### Using Xcode

1. **Create a new Xcode project:**
   - For iOS: Choose "iOS" → "App" template
   - For macOS: Choose "macOS" → "App" template
   - Product Name: `PPTXViewer`
   - Interface: SwiftUI
   - Language: Swift

2. **Add PPTXKit as a dependency:**
   - In Xcode, select your project in the navigator
   - Select your target
   - Go to "General" tab → "Frameworks, Libraries, and Embedded Content"
   - Click "+" and select "Add Package Dependency"
   - Enter the path to the PPTXKit package: `file:///path/to/pptx-swift`
   - Select "PPTXKit" library

3. **Copy the source files:**
   - Replace the default `ContentView.swift` with the one from this sample
   - Replace the default `App.swift` with `PPTXViewerApp.swift`
   - Update `Info.plist` with the provided configuration

4. **Build and run:**
   - Select your target device/simulator
   - Press Cmd+R to build and run

### Using Swift Package Manager

Alternatively, you can build the apps using Swift Package Manager:

```bash
# For iOS app
cd SampleApps/PPTXViewer-iOS
swift build

# For macOS app
cd SampleApps/PPTXViewer-macOS
swift build
```

## Features Demonstrated

### File Handling
- Document picker integration
- Security-scoped resource handling
- File type associations

### Presentation Management
- PPTXManager for state management
- Navigation between slides
- Progress tracking
- Error handling

### UI Components
- PPTXPresentationView for slide display
- PPTXThumbnailGridView for grid layout
- Custom navigation controls
- Responsive layouts

### Platform-Specific Features

**iOS:**
- Tab bar interface
- Touch gestures
- File sharing support
- Universal app (iPhone & iPad)

**macOS:**
- Menu bar integration
- Keyboard shortcuts
- Split view interface
- Window management

## Code Structure

### iOS App
```
PPTXViewer-iOS/
├── PPTXViewerApp.swift      # App entry point
├── ContentView.swift        # Main UI
├── Info.plist              # App configuration
└── Package.swift           # SPM configuration
```

### macOS App
```
PPTXViewer-macOS/
├── PPTXViewerApp.swift      # App entry point
├── ContentView.swift        # Main UI with split view
├── Info.plist              # App configuration
└── Package.swift           # SPM configuration
```

## Customization

### Changing the UI
- Modify `ContentView.swift` to customize the interface
- Adjust rendering quality: `.renderingQuality(.high)`
- Toggle navigation controls: `.navigationControlsVisible(true)`
- Customize colors and styling

### Adding Features
- Implement export functionality
- Add annotation support
- Create presenter notes view
- Add slide transitions

### Handling Different File Types
- Extend file type support in Info.plist
- Add converters for other formats
- Implement preview extensions

## Common Tasks

### Opening Files
```swift
func loadPresentation(from url: URL) {
    do {
        try manager.loadPresentation(from: url.path)
    } catch {
        // Handle error
    }
}
```

### Navigation
```swift
// Basic navigation
manager.goToNext()
manager.goToPrevious()
manager.goToSlide(at: 5)

// Check navigation state
if manager.canGoNext {
    manager.goToNext()
}
```

### Search
```swift
let results = manager.searchSlides(containing: "revenue")
for slide in results {
    print("Found in slide \(slide.index)")
}
```

## Troubleshooting

### File Access Issues
- Ensure proper entitlements for file access
- Handle security-scoped resources correctly
- Check file permissions

### Performance
- Use appropriate rendering quality
- Consider thumbnail caching for large files
- Profile with Instruments

### Memory Usage
- Monitor memory with large presentations
- Implement proper cleanup
- Use lazy loading where appropriate

## License

These sample apps are provided as examples and can be freely modified and used in your own projects.
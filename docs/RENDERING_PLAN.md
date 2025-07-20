# PPTX Slide Rendering Feature Plan

**Status: Implemented** ✅

## Overview

Add the capability to render PPTX slides as native views on iOS and macOS platforms. This feature will allow developers to display PowerPoint slides within their applications without requiring Microsoft Office or web views.

## Goals

1. **Cross-platform Support**: Work on both iOS (UIView) and macOS (NSView)
2. **SwiftUI Integration**: Provide SwiftUI views for modern app development
3. **Performance**: Efficient rendering with proper caching
4. **Fidelity**: Accurate representation of slide content within reasonable limits
5. **Flexibility**: Support rendering by slide index or ID

## Architecture Design

### Component Structure

```
PPTXKit (existing)
    └── Rendering (new)
        ├── Core
        │   ├── SlideRenderer.swift
        │   ├── RenderingContext.swift
        │   └── GeometryCalculator.swift
        ├── Elements
        │   ├── ShapeRenderer.swift
        │   ├── TextRenderer.swift
        │   ├── ImageRenderer.swift
        │   └── PlaceholderRenderer.swift
        ├── Platform
        │   ├── PPTXSlideView.swift (NSView/UIView)
        │   └── PPTXSlideViewRepresentable.swift (SwiftUI)
        └── Utils
            ├── ColorParser.swift
            ├── FontMapper.swift
            └── TransformCalculator.swift
```

### Rendering Pipeline

```
1. Parse Slide XML
   ↓
2. Build Render Tree
   ↓
3. Calculate Layout
   ↓
4. Apply Transforms
   ↓
5. Render Elements
   ↓
6. Composite Final View
```

## API Design

### UIKit/AppKit API

```swift
// Platform-agnostic base class
public class PPTXSlideView: PlatformView {
    // Initialize with a slide
    public init(slide: Slide, frame: CGRect)
    
    // Initialize with document and slide reference
    public init(document: PPTXDocument, slideIndex: Int)
    public init(document: PPTXDocument, slideId: String)
    
    // Rendering options
    public var renderingScale: CGFloat = 1.0
    public var backgroundColor: PlatformColor?
    public var renderingQuality: RenderingQuality = .balanced
    
    // Refresh rendering
    public func setNeedsRender()
    
    // Export rendered image
    public func renderToImage() -> PlatformImage?
}

#if os(macOS)
public typealias PlatformView = NSView
public typealias PlatformColor = NSColor
public typealias PlatformImage = NSImage
#else
public typealias PlatformView = UIView
public typealias PlatformColor = UIColor
public typealias PlatformImage = UIImage
#endif
```

### SwiftUI API

```swift
public struct PPTXSlideView: View {
    let slide: Slide
    
    // Initializers
    public init(slide: Slide)
    public init(document: PPTXDocument, slideIndex: Int)
    public init(document: PPTXDocument, slideId: String)
    
    // View modifiers
    public func renderingScale(_ scale: CGFloat) -> PPTXSlideView
    public func renderingQuality(_ quality: RenderingQuality) -> PPTXSlideView
    
    public var body: some View {
        // Implementation using ViewRepresentable
    }
}

// Usage in SwiftUI
struct ContentView: View {
    let document: PPTXDocument
    
    var body: some View {
        PPTXSlideView(document: document, slideIndex: 1)
            .renderingScale(2.0)
            .frame(width: 400, height: 300)
    }
}
```

### Rendering Options

```swift
public enum RenderingQuality {
    case low      // Fast rendering, basic shapes
    case balanced // Good quality/performance balance
    case high     // Best quality, all effects
}

public struct RenderingOptions {
    var quality: RenderingQuality = .balanced
    var renderText: Bool = true
    var renderImages: Bool = true
    var renderShapes: Bool = true
    var renderBackground: Bool = true
    var imageLoadingTimeout: TimeInterval = 5.0
}
```

## Implementation Phases

### Phase 1: Basic Shape Rendering (Week 1-2)
- [ ] Create platform-specific view classes
- [ ] Implement basic shape rendering (rectangles, circles)
- [ ] Add coordinate system transformation
- [ ] Support solid fill colors
- [ ] Basic text rendering without formatting

### Phase 2: Advanced Shapes & Styling (Week 3-4)
- [ ] Complex shape paths (arrows, stars, etc.)
- [ ] Gradient fills (linear, radial)
- [ ] Border/stroke styling
- [ ] Shape effects (shadows, reflections)
- [ ] Shape transformations (rotation, scaling)

### Phase 3: Text Rendering (Week 5-6)
- [ ] Rich text formatting (bold, italic, underline)
- [ ] Font mapping (Windows → System fonts)
- [ ] Text alignment and spacing
- [ ] Bullet points and numbering
- [ ] Text boxes with wrapping

### Phase 4: Image & Media Support (Week 7-8)
- [ ] Image extraction and display
- [ ] Image transformations and cropping
- [ ] Placeholder handling for missing media
- [ ] Lazy loading for performance
- [ ] Memory management for large images

### Phase 5: Advanced Features (Week 9-10)
- [ ] Master slide backgrounds
- [ ] Theme color support
- [ ] Charts and diagrams (basic)
- [ ] Tables
- [ ] Animations (static preview)

### Phase 6: SwiftUI & Optimization (Week 11-12)
- [ ] SwiftUI view wrapper
- [ ] Rendering cache system
- [ ] Async rendering for large slides
- [ ] Performance profiling
- [ ] Memory optimization

## Technical Considerations

### XML to Visual Mapping

```swift
// Example: Shape XML to rendering
<p:sp>
    <p:spPr>
        <a:xfrm>
            <a:off x="1000" y="2000"/>
            <a:ext cx="3000" cy="4000"/>
        </a:xfrm>
        <a:prstGeom prst="rect">
        <a:solidFill>
            <a:srgbClr val="FF0000"/>
        </a:solidFill>
    </p:spPr>
</p:sp>

// Renders as:
CGRect(x: 1000/12700, y: 2000/12700, 
       width: 3000/12700, height: 4000/12700)
fillColor: UIColor.red
```

### Coordinate System
- PPTX uses EMUs (English Metric Units)
- 1 inch = 914,400 EMUs
- 1 point = 12,700 EMUs
- Need conversion to points/pixels

### Font Mapping Strategy
```swift
let fontMap = [
    "Calibri": "Helvetica Neue",
    "Arial": "Helvetica",
    "Times New Roman": "Times",
    "Comic Sans MS": "Marker Felt",
    // ... more mappings
]
```

### Performance Optimizations
1. **Render Tree Caching**: Cache parsed render trees
2. **Image Caching**: LRU cache for decoded images
3. **Lazy Rendering**: Only render visible content
4. **Background Rendering**: Use background queues
5. **Level of Detail**: Reduce quality when zoomed out

## Testing Strategy

### Unit Tests
- Shape rendering accuracy
- Color parsing
- Transform calculations
- Font mapping

### Visual Tests
- Screenshot comparison tests
- Known slide rendering tests

## Implementation Status

### Completed ✅
- **Core Architecture**: All rendering components implemented
- **Platform Views**: PPTXSlideView for UIKit/AppKit
- **SwiftUI Support**: PPTXSlideViewUI wrapper
- **Basic Rendering**: SlideRenderer with placeholder content
- **Shape Rendering**: Rectangle, ellipse, arrow, star shapes
- **Text Rendering**: Basic text with font mapping
- **Image Support**: Image renderer structure
- **Quality Settings**: Low, balanced, high rendering modes
- **Coordinate Conversion**: EMU to points/pixels
- **Font Mapping**: Windows to system font mapping
- **Cross-Platform**: iOS and macOS support

### In Progress 🚧
- **XML Parsing**: Full slide XML structure parsing
- **Complex Shapes**: Additional shape types
- **Effects**: Shadows, gradients, transparency
- **Layout Engine**: Proper text flow and alignment

### Future Enhancements 📋
- **Animations**: Slide transitions and animations
- **Media**: Video and audio support
- **Charts**: Chart rendering
- **Tables**: Table rendering
- **Smart Art**: SmartArt diagram support
- **Themes**: Full theme support
- **Master Slides**: Master slide inheritance
- Edge case handling

### Performance Tests
- Rendering time benchmarks
- Memory usage profiling
- Stress tests with complex slides

## Limitations & Scope

### In Scope
- Basic shapes and text
- Images and simple fills
- Common fonts and styles
- Static rendering

### Out of Scope (Initially)
- Animations and transitions
- Video/audio playback
- Complex SmartArt
- 3D effects
- Embedded objects (Excel, etc.)
- Perfect font matching

## Dependencies

### Required
- Core Graphics (iOS/macOS)
- Core Text (iOS/macOS)
- ImageIO (for image handling)

### Optional
- Metal (for GPU acceleration)
- PDFKit (for PDF export)

## Example Usage

### UIKit
```swift
let document = try PPTXDocument(filePath: "presentation.pptx")
let slideView = PPTXSlideView(document: document, slideIndex: 1)
slideView.renderingQuality = .high
view.addSubview(slideView)
```

### SwiftUI
```swift
struct PresentationView: View {
    @State var currentSlide = 1
    let document: PPTXDocument
    
    var body: some View {
        VStack {
            PPTXSlideView(document: document, slideIndex: currentSlide)
                .renderingQuality(.high)
                .aspectRatio(4/3, contentMode: .fit)
            
            HStack {
                Button("Previous") { currentSlide -= 1 }
                Text("Slide \(currentSlide)")
                Button("Next") { currentSlide += 1 }
            }
        }
    }
}
```

## Success Criteria

1. **Accuracy**: 80%+ visual fidelity for common slides
2. **Performance**: < 100ms render time for typical slides
3. **Memory**: < 50MB for typical presentation
4. **Compatibility**: Works on iOS 14+ and macOS 11+
5. **API**: Intuitive and Swift-friendly

## Next Steps

1. Review and refine the plan
2. Set up rendering test harness
3. Begin Phase 1 implementation
4. Create visual test suite
5. Gather feedback on API design
# PPTXKit Rendering Implementation Plan

## Overview
This document outlines the implementation plan to fully render sample_2.pptx and similar presentations based on ECMA-376 specifications.

## Current Status vs Requirements

### ✅ Already Working
1. Basic slide structure parsing
2. Rectangle and ellipse shapes
3. Solid color fills
4. Basic text extraction
5. Coordinate system (fixed for iOS)

### ❌ Missing for sample_2.pptx
1. **Star shapes** (star5 preset geometry)
2. **Theme color resolution** (accent1, lt1, etc.)
3. **Gradient fills**
4. **Proper text formatting** (bullets, alignment)
5. **Image rendering**
6. **Table rendering**

## Implementation Phases

### Phase 1: Preset Shape Geometries (Priority: HIGH)
Based on the ECMA-376 presetShapeDefinitions.xml, we need to implement shape path generation.

#### 1.1 Shape Path Parser
```swift
// New file: Sources/PPTXKit/Rendering/Geometry/PresetShapeParser.swift
public class PresetShapeParser {
    // Parse shape definitions from XML
    static func loadShapeDefinitions() -> [String: ShapeDefinition]
    
    // Generate CGPath from shape type
    func createPath(for shapeType: String, in bounds: CGRect) -> CGPath
}

struct ShapeDefinition {
    let adjustments: [Adjustment]
    let guides: [Guide]
    let pathList: [ShapePath]
}
```

#### 1.2 Common Shapes to Implement
From sample_2.pptx analysis:
- `star5` - 5-pointed star
- `rect` - Rectangle (already done)
- `ellipse` - Ellipse (already done)  
- `roundRect` - Rounded rectangle
- `triangle` - Triangle (for future)
- `arrow` - Arrow shapes

### Phase 2: Theme Color Support (Priority: HIGH)

#### 2.1 Theme Parser
```swift
// New file: Sources/PPTXKit/Core/Theme/ThemeParser.swift
public class ThemeParser {
    func parseTheme(from archive: Archive) throws -> Theme
}

public struct Theme {
    let colorScheme: ColorScheme
    let fontScheme: FontScheme
    let formatScheme: FormatScheme
}

public struct ColorScheme {
    let accent1: String  // e.g., "#4472C4"
    let accent2: String
    let accent3: String
    let accent4: String
    let accent5: String
    let accent6: String
    let light1: String   // Usually white
    let light2: String
    let dark1: String    // Usually black
    let dark2: String
    let hyperlink: String
    let followedHyperlink: String
}
```

#### 2.2 Color Resolution
```swift
extension SlideRenderer {
    func resolveColor(_ colorRef: String, with theme: Theme) -> CGColor {
        // Handle scheme colors like "accent1", "lt1", etc.
        // Apply tints and shades
    }
}
```

### Phase 3: Gradient Support (Priority: MEDIUM)

#### 3.1 Gradient Parser
```swift
struct GradientStop {
    let position: CGFloat
    let color: CGColor
}

enum GradientType {
    case linear(angle: CGFloat)
    case radial(center: CGPoint)
    case path
}
```

### Phase 4: Enhanced Text Rendering (Priority: MEDIUM)

#### 4.1 Text Features
- Bullet points (`<a:buChar>`)
- Numbered lists (`<a:buAutoNum>`)
- Text alignment (left, center, right, justify)
- Paragraph spacing
- Font attributes (bold, italic, underline)

#### 4.2 Text Layout Engine
```swift
extension TextRenderer {
    func renderParagraph(_ paragraph: Paragraph, in bounds: CGRect) {
        // Handle bullets/numbering
        // Apply paragraph properties
        // Layout text runs
    }
}
```

### Phase 5: Image Support (Priority: MEDIUM)

#### 5.1 Image Extraction
```swift
extension ImageRenderer {
    func extractImage(from relationship: Relationship, in archive: Archive) -> CGImage? {
        // Resolve image path (e.g., "../media/image1.png")
        // Extract from archive
        // Decode image data
    }
}
```

### Phase 6: Table Rendering (Priority: LOW)

#### 6.1 Table Parser
```swift
struct Table {
    let rows: [TableRow]
    let columns: [TableColumn]
    let cells: [[TableCell]]
}
```

## File Structure Updates

```
Sources/PPTXKit/
├── Core/
│   ├── Theme/
│   │   ├── ThemeParser.swift
│   │   └── Theme.swift
│   └── ...
├── Rendering/
│   ├── Geometry/
│   │   ├── PresetShapeParser.swift
│   │   ├── ShapeDefinitions.swift
│   │   └── PathBuilder.swift
│   ├── Elements/
│   │   ├── ShapeRenderer.swift (update)
│   │   ├── TextRenderer.swift (enhance)
│   │   └── TableRenderer.swift (new)
│   └── ...
└── Resources/
    └── presetShapes.json (converted from XML)
```

## Testing Strategy

### 1. Visual Tests
Create reference images for each slide of sample_2.pptx:
```bash
# Using LibreOffice
soffice --headless --convert-to pdf sample_2.pptx
convert -density 300 sample_2.pdf slide-%d.png
```

### 2. Unit Tests
- Test each preset shape individually
- Test theme color resolution
- Test gradient rendering
- Test text formatting

### 3. Integration Tests
- Full slide rendering
- Compare with reference images
- Performance benchmarks

## Implementation Order

1. **Week 1**: Theme color support (required for all shapes in sample_2)
2. **Week 2**: Preset shape geometries (star5, etc.)
3. **Week 3**: Gradient fills
4. **Week 4**: Enhanced text rendering
5. **Week 5**: Image support
6. **Week 6**: Tables and testing

## Success Metrics

1. **sample_2.pptx renders correctly**:
   - All shapes visible with correct colors
   - Text properly formatted
   - Images displayed
   - Tables rendered

2. **Performance**:
   - < 100ms per slide rendering
   - < 10MB memory per slide

3. **Code Quality**:
   - 90%+ test coverage
   - Clear documentation
   - Extensible architecture

## Next Steps

1. Start with theme parsing to resolve "accent1" colors
2. Implement star5 shape for slide 4
3. Add gradient support for enhanced visuals
4. Test with sample_2.pptx throughout development
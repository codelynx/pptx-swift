# PPTXKit Implementation Roadmap - Small Steps Approach

## Overview
This roadmap breaks down the implementation into small, manageable steps. Each step should take 1-3 days and produce a working feature.

## Current Status
- ✅ Basic rendering infrastructure
- ✅ Rectangle shape
- ✅ Ellipse shape
- ✅ Solid color fills
- ✅ Basic text extraction
- ❌ 184 remaining shapes
- ❌ Theme support
- ❌ Gradients, patterns, effects

## Phase 1: Foundation (1-2 weeks)

### Step 1.1: Theme Color Support (2-3 days)
**Goal**: Resolve "accent1" colors in sample_2.pptx

```swift
// New files:
Sources/PPTXKit/Core/Theme/ThemeParser.swift
Sources/PPTXKit/Core/Theme/Theme.swift
```

**Tasks**:
1. Parse `ppt/theme/theme1.xml` from PPTX
2. Extract color scheme (accent1-6, light1-2, dark1-2)
3. Update `SlideRenderer` to resolve theme colors
4. Test with sample_2.pptx shapes (should show blue instead of gray)

**Success**: Shapes in sample_2.pptx render with correct blue color

### Step 1.2: Rounded Rectangle (1 day)
**Goal**: Implement the most common shape after rectangle

```swift
case .roundRect(cornerRadius: CGFloat)
```

**Tasks**:
1. Add `roundRect` to `ShapeData.ShapeType`
2. Implement path generation using `CGPath(roundedRect:)`
3. Parse corner radius from XML
4. Add unit test

**Success**: Rounded rectangles render correctly

### Step 1.3: Line Shape (1 day)
**Goal**: Support basic lines and connectors

```swift
case .line(start: CGPoint, end: CGPoint)
```

**Tasks**:
1. Add line shape type
2. Handle line-specific properties (no fill, only stroke)
3. Test with straight connectors
4. Support different line endings (arrows later)

**Success**: Lines render with proper stroke

## Phase 2: Essential Arrows (1 week)

### Step 2.1: Right Arrow (2 days)
**Goal**: First arrow shape implementation

**Tasks**:
1. Create `ArrowPathBuilder` class
2. Parse arrow shape formula from spec
3. Implement path calculation
4. Test with different sizes

**Success**: Right arrow renders correctly

### Step 2.2: Other Basic Arrows (2 days)
**Goal**: Complete 4-directional arrows

**Tasks**:
1. Reuse arrow path logic
2. Add rotation transforms for left/up/down
3. Test arrow set together
4. Create visual test page

**Success**: All 4 arrows render correctly

### Step 2.3: Double-Headed Arrows (1 day)
**Goal**: Bidirectional arrows

**Tasks**:
1. Extend arrow builder for double heads
2. Implement leftRightArrow, upDownArrow
3. Ensure proper proportions

**Success**: Double arrows render correctly

## Phase 3: Common Shapes (1 week)

### Step 3.1: Triangle (1 day)
**Goal**: Basic triangle shape

**Tasks**:
1. Implement isosceles triangle path
2. Add right triangle variant
3. Test different orientations

**Success**: Triangles render correctly

### Step 3.2: Star5 Shape (2 days)
**Goal**: Render star from sample_2.pptx

**Tasks**:
1. Parse star5 definition from spec
2. Implement complex path with inner/outer radius
3. Handle adjustment values
4. Test with sample_2.pptx

**Success**: Star renders correctly in sample_2.pptx

### Step 3.3: Diamond & Hexagon (2 days)
**Goal**: Common polygon shapes

**Tasks**:
1. Create polygon path builder
2. Implement diamond (4 sides)
3. Implement hexagon (6 sides)
4. Add octagon as bonus

**Success**: Polygons render correctly

## Phase 4: Gradients & Effects (1 week)

### Step 4.1: Linear Gradient (2 days)
**Goal**: Two-color linear gradients

**Tasks**:
1. Parse gradient fill from XML
2. Extract colors and positions
3. Apply gradient in ShapeRenderer
4. Test with sample slides

**Success**: Linear gradients render

### Step 4.2: Radial Gradient (1 day)
**Goal**: Center-to-edge gradients

**Tasks**:
1. Extend gradient parser
2. Implement radial gradient rendering
3. Handle focal points

**Success**: Radial gradients render

### Step 4.3: Basic Shadow (2 days)
**Goal**: Simple drop shadows

**Tasks**:
1. Parse shadow effects
2. Implement shadow rendering
3. Handle shadow color and offset
4. Test performance impact

**Success**: Shadows appear correctly

## Phase 5: Text Enhancements (1 week)

### Step 5.1: Bullet Points (2 days)
**Goal**: Render bullet lists properly

**Tasks**:
1. Parse bullet characters
2. Implement bullet rendering
3. Handle indentation
4. Test with sample slides

**Success**: Bullets render correctly

### Step 5.2: Text Alignment (1 day)
**Goal**: Left/center/right/justify

**Tasks**:
1. Parse alignment from XML
2. Update text renderer
3. Handle multi-line text
4. Test all alignments

**Success**: Text aligns properly

### Step 5.3: Font Styles (2 days)
**Goal**: Bold, italic, underline

**Tasks**:
1. Parse text run properties
2. Apply font attributes
3. Handle mixed styles in paragraph
4. Test with various fonts

**Success**: Font styles render correctly

## Milestones & Validation

### Milestone 1 (End of Phase 1)
- [ ] sample_2.pptx shapes have correct colors
- [ ] Basic shapes beyond rect/ellipse work
- [ ] Performance <10ms per shape

### Milestone 2 (End of Phase 3)
- [ ] sample_2.pptx renders 90% correctly
- [ ] Top 20 shapes implemented
- [ ] Visual regression tests pass

### Milestone 3 (End of Phase 5)
- [ ] Professional-looking slide rendering
- [ ] Text formatting complete
- [ ] Ready for production use

## Testing Strategy

### For Each Step:
1. **Unit Test**: Test the specific feature
2. **Visual Test**: Render and manually verify
3. **Regression Test**: Ensure nothing broke
4. **Performance Test**: Measure render time

### Test Files:
```
Tests/Resources/
├── shapes/
│   ├── basic_shapes.pptx
│   ├── arrows.pptx
│   ├── stars_banners.pptx
│   └── gradients.pptx
├── reference/
│   └── [PNG files from PowerPoint]
```

## Code Organization

```
Sources/PPTXKit/
├── Core/
│   └── Theme/
│       ├── ThemeParser.swift
│       └── ColorScheme.swift
├── Rendering/
│   ├── Geometry/
│   │   ├── ShapePathBuilder.swift
│   │   ├── ArrowPathBuilder.swift
│   │   ├── StarPathBuilder.swift
│   │   └── PolygonPathBuilder.swift
│   ├── Effects/
│   │   ├── GradientRenderer.swift
│   │   └── ShadowRenderer.swift
│   └── Text/
│       ├── BulletRenderer.swift
│       └── TextStyler.swift
```

## Daily Progress Tracking

### Week 1 Checklist:
- [ ] Mon: Start theme parser
- [ ] Tue: Complete theme colors
- [ ] Wed: Test with sample_2.pptx
- [ ] Thu: Implement roundRect
- [ ] Fri: Implement line shape

### Week 2 Checklist:
- [ ] Mon: Right arrow research
- [ ] Tue: Right arrow implementation
- [ ] Wed: Other arrows
- [ ] Thu: Double arrows
- [ ] Fri: Arrow testing & cleanup

## Success Metrics

1. **Correctness**: Shapes match PowerPoint rendering
2. **Performance**: <10ms per shape on average
3. **Coverage**: Top 20 shapes = 95% of use cases
4. **Quality**: Clean, documented, tested code

## Next Action

**Start with Step 1.1**: Create `ThemeParser.swift` and begin parsing theme1.xml to resolve the "accent1" colors in sample_2.pptx.
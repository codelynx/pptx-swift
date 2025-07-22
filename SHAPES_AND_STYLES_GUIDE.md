# PPTX Shapes and Styles Implementation Guide

## Overview
This guide provides a comprehensive list of shapes and styles in PowerPoint (ECMA-376), categorized by implementation priority based on real-world usage.

## Shape Statistics
- **Total Preset Shapes**: 186 defined in ECMA-376
- **Commonly Used**: ~20 shapes cover 95% of typical presentations
- **Already Implemented**: 2 (rectangle, ellipse)

## Implementation Phases

### Phase 1: Essential Shapes (Week 1)
These shapes appear in almost every presentation and should be implemented first.

#### 1.1 Basic Geometric Shapes
- [x] **rectangle** (`rect`) - Basic rectangle
- [x] **ellipse** - Circle and oval shapes
- [ ] **roundRect** - Rounded rectangle (very common)
- [ ] **triangle** - Isosceles triangle
- [ ] **rightTriangle** - Right-angled triangle
- [ ] **parallelogram** - Slanted rectangle
- [ ] **trapezoid** - Trapezoid shape
- [ ] **diamond** - Diamond/rhombus shape
- [ ] **octagon** - 8-sided polygon
- [ ] **hexagon** - 6-sided polygon

**Usage**: Found in 90%+ of presentations for basic layouts and diagrams.

### Phase 2: Arrows & Lines (Week 2)
Essential for diagrams and flow charts.

#### 2.1 Basic Arrows
- [ ] **rightArrow** - Simple right-pointing arrow
- [ ] **leftArrow** - Simple left-pointing arrow  
- [ ] **upArrow** - Simple up-pointing arrow
- [ ] **downArrow** - Simple down-pointing arrow
- [ ] **leftRightArrow** - Double-headed horizontal arrow
- [ ] **upDownArrow** - Double-headed vertical arrow
- [ ] **bentArrow** - 90-degree bent arrow
- [ ] **uturnArrow** - U-turn shaped arrow

#### 2.2 Lines & Connectors
- [ ] **line** - Straight line
- [ ] **straightConnector1** - Straight connector
- [ ] **bentConnector2** - L-shaped connector
- [ ] **bentConnector3** - Z-shaped connector
- [ ] **curvedConnector2** - Simple curved connector

**Usage**: Critical for flowcharts, process diagrams, and relationships.

### Phase 3: Stars & Banners (Week 3)
Decorative shapes used for highlighting.

#### 3.1 Star Shapes
- [ ] **star4** - 4-pointed star
- [ ] **star5** - 5-pointed star (used in sample_2.pptx)
- [ ] **star6** - 6-pointed star
- [ ] **star8** - 8-pointed star
- [ ] **star16** - 16-pointed star (sunburst)

#### 3.2 Banners & Ribbons
- [ ] **ribbon** - Simple ribbon banner
- [ ] **ribbon2** - Curved ribbon banner
- [ ] **ellipseRibbon** - Elliptical ribbon
- [ ] **verticalScroll** - Vertical scroll/banner
- [ ] **horizontalScroll** - Horizontal scroll/banner

**Usage**: Common in titles, certificates, and promotional materials.

### Phase 4: Callouts & Speech Bubbles (Week 4)
Used for annotations and comments.

#### 4.1 Basic Callouts
- [ ] **wedgeRectCallout** - Rectangular callout
- [ ] **wedgeRoundRectCallout** - Rounded rectangular callout
- [ ] **wedgeEllipseCallout** - Elliptical callout
- [ ] **cloudCallout** - Cloud-shaped callout
- [ ] **borderCallout1** - Callout with line border
- [ ] **callout1** - Simple callout with pointer

**Usage**: Essential for presentations with annotations or dialogue.

### Phase 5: Flowchart Shapes (Week 5)
Standard flowchart symbols.

#### 5.1 Core Flowchart Shapes
- [ ] **flowChartProcess** - Rectangle (process)
- [ ] **flowChartDecision** - Diamond (decision)
- [ ] **flowChartTerminator** - Rounded rectangle (start/end)
- [ ] **flowChartData** - Parallelogram (input/output)
- [ ] **flowChartDocument** - Document shape
- [ ] **flowChartManualInput** - Manual input shape
- [ ] **flowChartPreparation** - Hexagon (preparation)
- [ ] **flowChartConnector** - Circle (connector)

**Usage**: Critical for technical and business process documentation.

### Phase 6: Advanced Shapes (Week 6+)
Less common but still useful shapes.

#### 6.1 Special Shapes
- [ ] **heart** - Heart shape (used in samples)
- [ ] **sun** - Sun shape
- [ ] **moon** - Crescent moon
- [ ] **smileyFace** - Smiley face
- [ ] **lightningBolt** - Lightning bolt
- [ ] **cloud** - Cloud shape
- [ ] **gear6** - 6-tooth gear
- [ ] **cube** - 3D cube

#### 6.2 Math & Symbols
- [ ] **mathPlus** - Plus sign
- [ ] **mathMinus** - Minus sign
- [ ] **mathMultiply** - Multiplication sign
- [ ] **mathDivide** - Division sign
- [ ] **mathEqual** - Equal sign
- [ ] **mathNotEqual** - Not equal sign

## Style Implementation Phases

### Phase 1: Core Styles (Alongside Shape Phase 1)
Essential styling needed for basic rendering.

#### 1.1 Fill Styles
- [x] **Solid Fill** - Single color fill
- [ ] **Gradient Fill** - Linear and radial gradients
- [ ] **No Fill** - Transparent fill

#### 1.2 Line Styles  
- [x] **Solid Line** - Basic line/border
- [ ] **Dashed Line** - Various dash patterns
- [ ] **No Line** - No border

#### 1.3 Theme Colors
- [ ] **accent1-6** - Theme accent colors
- [ ] **light1-2** - Light theme colors
- [ ] **dark1-2** - Dark theme colors
- [ ] **Tints/Shades** - Color variations (10%, 25%, 50%, etc.)

### Phase 2: Advanced Fills (Week 3-4)
More complex fill styles.

#### 2.1 Pattern & Texture Fills
- [ ] **Pattern Fill** - Repeating patterns
- [ ] **Picture Fill** - Image as fill
- [ ] **Texture Fill** - Texture patterns

#### 2.2 Gradient Types
- [ ] **Linear Gradient** - Two or more colors
- [ ] **Radial Gradient** - Center to edge
- [ ] **Rectangular Gradient** - From corners
- [ ] **Path Gradient** - Along shape path

### Phase 3: Effects (Week 5-6)
Visual effects for professional appearance.

#### 3.1 Shadow Effects
- [ ] **Outer Shadow** - Drop shadow
- [ ] **Inner Shadow** - Inside shadow
- [ ] **Perspective Shadow** - 3D shadow

#### 3.2 Other Effects
- [ ] **Reflection** - Mirror effect
- [ ] **Glow** - Outer/inner glow
- [ ] **Soft Edges** - Blurred edges
- [ ] **3D Format** - Bevel and depth

### Phase 4: Text Styles (Week 4-5)
Text formatting and effects.

#### 4.1 Text Formatting
- [ ] **Bold/Italic/Underline** - Basic formatting
- [ ] **Font Families** - Font mapping
- [ ] **Text Alignment** - Left/center/right/justify
- [ ] **Line Spacing** - Paragraph spacing
- [ ] **Bullets & Numbering** - Lists

#### 4.2 Text Effects
- [ ] **Text Fill** - Solid/gradient/picture
- [ ] **Text Outline** - Border around text
- [ ] **Text Shadow** - Drop shadow on text
- [ ] **WordArt Styles** - Preset text effects

## Implementation Priority Matrix

### Must Have (Phase 1-2)
- Basic shapes (rect, roundRect, ellipse, triangle)
- Basic arrows (4 directions)
- Solid fills and lines
- Theme color support
- Basic text formatting

### Should Have (Phase 3-4)
- Stars and banners
- Callouts
- Gradient fills
- Shadows
- Advanced text formatting

### Nice to Have (Phase 5-6)
- Flowchart shapes
- Special shapes
- Pattern fills
- 3D effects
- WordArt

## Testing Strategy

### For Each Phase:
1. **Unit Tests**: Test shape/style generation
2. **Visual Tests**: Render and compare with PowerPoint
3. **Performance Tests**: Ensure <10ms per shape
4. **Integration Tests**: Combine with existing features

### Test Files:
- Create specific PPTX files for each phase
- Use sample_2.pptx as baseline (has star5, themes)
- Add complexity gradually

## Success Metrics

### Phase Completion:
- All shapes render correctly
- Styles apply properly
- Performance targets met
- Tests passing

### Overall Goals:
- 95% of real presentations renderable by Phase 3
- 99% by Phase 5
- Full spec compliance by Phase 6

## Next Steps

1. **Start with Phase 1.1**: Implement remaining basic shapes
2. **Add Theme Support**: Parse and apply theme colors
3. **Test with sample_2.pptx**: Ensure star5 renders correctly
4. **Iterate**: Each phase builds on previous work

## Resources

- Shape definitions: `/specifications/resources/drawingml/presetShapeDefinitions.xml`
- Theme structure: Part 1 PDF, Section 14.2.7
- Fill types: Part 1 PDF, Section 20.1.8
- Effect types: Part 1 PDF, Section 20.1.3
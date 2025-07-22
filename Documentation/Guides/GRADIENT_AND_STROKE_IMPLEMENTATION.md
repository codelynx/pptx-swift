# Gradient and Stroke Implementation

## Overview

This document describes the implementation of gradient fills and stroke rendering in PPTXKit, including support for luminance modifications, theme colors, and no-fill shapes.

## Features Implemented

### 1. Gradient Fill Support

#### Linear Gradients
- Parse `<a:gradFill>` elements with `<a:lin>` for linear gradients
- Support gradient angle from PPTX format (60000ths of a degree)
- Multiple gradient stops with position values
- Theme color support in gradients

#### Gradient Color Stops
- Parse `<a:gs>` (gradient stop) elements with position attributes
- Support both `<a:srgbClr>` and `<a:schemeClr>` within gradient stops
- Position values converted from percentage (0-100000) to normalized (0-1)

#### Luminance Modifications
- Parse `<a:lumMod>` (luminance modulation) and `<a:lumOff>` (luminance offset)
- Apply HSL color space transformations for accurate color variations
- Support values in percentage * 1000 format (e.g., 50000 = 50%)

### 2. Stroke/Border Support

#### Stroke Parsing
- Parse `<a:ln>` elements for shape borders/strokes
- Extract stroke width from `w` attribute (EMU units)
- Support stroke colors from both `<a:srgbClr>` and `<a:schemeClr>`
- Theme color resolution for strokes

#### Stroke Rendering
- Apply strokes to all shape types (rectangles, ellipses, custom paths)
- Proper stroke width conversion from EMU to points
- Default black stroke when color not specified

### 3. No Fill Support

- Parse `<a:noFill/>` elements
- Override style-based fills when explicit no-fill is specified
- Render shapes with only strokes (no fill)

### 4. Additional Shape Support

#### New Shape Types
- **Heart**: Bezier curve-based heart shape
- **Polygons**: Triangle, pentagon, hexagon, octagon, dodecagon
- **Connectors**: Straight line connectors with no fill
- **Arrows**: Directional arrows (left, right, up, down, bidirectional)

## Implementation Details

### XML Parsing Flow

1. **Shape Properties** (`<p:spPr>`)
   - Reset all fill/stroke state variables
   - Parse child elements for geometry, fill, and stroke

2. **Fill Detection**
   - `<a:solidFill>`: Simple color fill
   - `<a:gradFill>`: Gradient fill with stops
   - `<a:noFill/>`: Explicit no fill
   - Style-based fill from `<p:style>/<a:fillRef>`

3. **Stroke Detection**
   - `<a:ln>`: Line/stroke element
   - Parse width attribute
   - Parse color from child elements

4. **Color Resolution**
   - Direct colors: `<a:srgbClr val="RRGGBB"/>`
   - Theme colors: `<a:schemeClr val="accent1"/>`
   - Apply luminance modifications if present

### Color Transformation Algorithm

```swift
// Luminance modification process:
1. Parse hex color to RGB
2. Convert RGB to HSL color space
3. Apply lumMod: L = L * (lumMod / 100000)
4. Apply lumOff: L = L + (lumOff / 100000)
5. Clamp L to [0, 1]
6. Convert back to RGB
7. Return as hex string
```

### Parser State Management

Key state variables added:
- `hasNoFill`: Tracks explicit no-fill directive
- `currentStrokeColor`: Current stroke color (hex)
- `currentStrokeWidth`: Current stroke width (points)
- `isInShapeLine`: Inside `<a:ln>` element
- `pendingGradientColorMods`: Luminance modifications for gradient stops
- `isInSchemeColor`: Inside scheme color element
- `pendingSchemeColor`: Theme color awaiting modifiers

### Rendering Pipeline

1. **Shape Creation**
   - Determine fill: Check hasNoFill, then currentFillColor, then styleFillColor
   - Create gradient if gradient colors exist
   - Create stroke style if hasStroke is true

2. **Gradient Rendering**
   - Convert gradient colors from hex to CGColor
   - Calculate gradient direction from angle
   - Create CGGradient with colors and locations
   - Apply linear gradient within shape bounds

3. **Stroke Rendering**
   - Use parsed stroke color or default to black
   - Apply stroke width (default 1.0 if not specified)
   - Render stroke after fill for proper layering

## Code Examples

### Gradient XML Example
```xml
<a:gradFill>
  <a:gsLst>
    <a:gs pos="0">
      <a:schemeClr val="accent1">
        <a:lumMod val="5000"/>
        <a:lumOff val="95000"/>
      </a:schemeClr>
    </a:gs>
    <a:gs pos="74000">
      <a:schemeClr val="accent1">
        <a:lumMod val="75000"/>
        <a:lumOff val="25000"/>
      </a:schemeClr>
    </a:gs>
  </a:gsLst>
  <a:lin ang="5400000" scaled="0"/>
</a:gradFill>
```

### Stroke XML Example
```xml
<a:ln w="79375">
  <a:solidFill>
    <a:schemeClr val="accent4"/>
  </a:solidFill>
</a:ln>
```

### No Fill Example
```xml
<p:spPr>
  <a:prstGeom prst="star5"/>
  <a:noFill/>
  <a:ln>
    <a:solidFill>
      <a:srgbClr val="FFC000"/>
    </a:solidFill>
  </a:ln>
</p:spPr>
```

## Testing

Test coverage includes:
- Shapes with gradients (rectangles, ellipses, hearts)
- Shapes with only strokes (stars, connectors)
- Theme color resolution in fills and strokes
- Luminance modifications creating proper gradient variations
- Various polygon shapes with different fill/stroke combinations

## Future Enhancements

1. **Gradient Types**
   - Radial gradients
   - Path gradients
   - Multiple gradient types per shape

2. **Stroke Features**
   - Dash patterns
   - Line caps and joins
   - Compound lines
   - Gradient strokes

3. **Effects**
   - Drop shadows
   - Reflections
   - Glow effects
   - 3D bevels

4. **Advanced Fills**
   - Pattern fills
   - Picture fills
   - Texture fills
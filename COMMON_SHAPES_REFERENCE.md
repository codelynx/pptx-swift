# Common PPTX Shapes - Quick Reference

## Top 20 Most Used Shapes (Cover ~95% of presentations)

### 1. Basic Shapes (Used in 90%+ presentations)
| Shape | ID | Description | Priority | Status |
|-------|-----|-------------|----------|---------|
| Rectangle | `rect` | Basic rectangle | CRITICAL | ✅ Done |
| Rounded Rectangle | `roundRect` | Rectangle with rounded corners | CRITICAL | ❌ TODO |
| Ellipse/Circle | `ellipse` | Oval and circular shapes | CRITICAL | ✅ Done |
| Line | `line` | Straight line | CRITICAL | ❌ TODO |

### 2. Arrows (Used in 70%+ presentations)
| Shape | ID | Description | Priority | Status |
|-------|-----|-------------|----------|---------|
| Right Arrow | `rightArrow` | Points right → | HIGH | ❌ TODO |
| Left Arrow | `leftArrow` | Points left ← | HIGH | ❌ TODO |
| Up Arrow | `upArrow` | Points up ↑ | HIGH | ❌ TODO |
| Down Arrow | `downArrow` | Points down ↓ | HIGH | ❌ TODO |
| Double Arrow | `leftRightArrow` | Points both ways ↔ | HIGH | ❌ TODO |

### 3. Common Shapes (Used in 50%+ presentations)
| Shape | ID | Description | Priority | Status |
|-------|-----|-------------|----------|---------|
| Triangle | `triangle` | Isosceles triangle | MEDIUM | ❌ TODO |
| Diamond | `diamond` | Diamond/rhombus shape | MEDIUM | ❌ TODO |
| Star | `star5` | 5-pointed star ⭐ | MEDIUM | ❌ TODO |
| Hexagon | `hexagon` | 6-sided polygon | MEDIUM | ❌ TODO |
| Chevron | `chevron` | Arrow-like shape | MEDIUM | ❌ TODO |

### 4. Callouts (Used in 30%+ presentations)
| Shape | ID | Description | Priority | Status |
|-------|-----|-------------|----------|---------|
| Speech Bubble | `wedgeRoundRectCallout` | Rounded callout | MEDIUM | ❌ TODO |
| Cloud Callout | `cloudCallout` | Cloud-shaped bubble | MEDIUM | ❌ TODO |
| Rectangle Callout | `wedgeRectCallout` | Square callout | MEDIUM | ❌ TODO |

### 5. Connectors (Used in 40%+ flowcharts)
| Shape | ID | Description | Priority | Status |
|-------|-----|-------------|----------|---------|
| Straight Connector | `straightConnector1` | Straight line connector | MEDIUM | ❌ TODO |
| Elbow Connector | `bentConnector2` | L-shaped connector | MEDIUM | ❌ TODO |

## Rare Shapes (< 5% usage)

### Examples of 166 rarely used shapes:
- `accentBorderCallout1-3` - Specialized callouts
- `actionButtonBackPrevious` - Media control buttons
- `chord` - Musical chord shape
- `dodecagon` - 12-sided polygon
- `gear6`, `gear9` - Gear shapes
- `halfFrame` - Half frame shape
- `mathDivide`, `mathEqual` - Math symbols
- `pie`, `pieWedge` - Pie chart shapes
- `teardrop` - Teardrop shape

## Implementation Strategy

### Week 1: Foundation (4 shapes)
```
✅ rect
✅ ellipse  
⏳ roundRect
⏳ line
```

### Week 2: Arrows (5 shapes)
```
⏳ rightArrow
⏳ leftArrow
⏳ upArrow
⏳ downArrow
⏳ leftRightArrow
```

### Week 3: Common Shapes (5 shapes)
```
⏳ triangle
⏳ diamond
⏳ star5 (needed for sample_2.pptx)
⏳ hexagon
⏳ chevron
```

### Week 4: Callouts & Connectors (6 shapes)
```
⏳ wedgeRoundRectCallout
⏳ cloudCallout
⏳ wedgeRectCallout
⏳ straightConnector1
⏳ bentConnector2
⏳ curvedConnector3
```

## Total Progress: 2/20 shapes (10%)

## Code Example for New Shape

```swift
// In ShapeRenderer.swift
private func createPath(for shapeType: ShapeData.ShapeType, in frame: CGRect) -> CGPath {
    switch shapeType {
    case .rectangle:
        return CGPath(rect: frame, transform: nil)
        
    case .ellipse:
        return CGPath(ellipseIn: frame, transform: nil)
        
    case .roundRect(let cornerRadius):
        return CGPath(roundedRect: frame, 
                     cornerWidth: cornerRadius, 
                     cornerHeight: cornerRadius, 
                     transform: nil)
        
    case .star5:
        return createStar5Path(in: frame)
        
    // Add more shapes here...
    }
}

private func createStar5Path(in frame: CGRect) -> CGPath {
    // Implementation based on presetShapeDefinitions.xml
    // Convert ECMA-376 formulas to Swift code
}
```

## Notes

1. **80/20 Rule**: 20 shapes cover 95% of use cases
2. **Priority**: Focus on shapes that appear in real presentations
3. **Testing**: Each shape needs visual regression tests
4. **Performance**: Simple shapes should render in <1ms
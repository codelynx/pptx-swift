# PowerPoint Shape Analysis

## Summary

Total preset shapes defined in `presetShapeDefinitions.xml`: **186 shapes**

## Shapes Used in Sample Presentations

From analyzing our sample PPTX files, the following shapes are actually used:
- `rect` - Rectangle (51 instances in sample1)
- `roundRect` - Rounded Rectangle (6 instances in sample1)
- `ellipse` - Ellipse/Circle (2 instances in sample2)
- `heart` - Heart (2 instances in sample2)
- `star5` - 5-Point Star (2 instances in sample2)
- `dodecagon` - 12-sided polygon (2 instances in sample2)
- `straightConnector1` - Straight Connector (2 instances in sample2)

## Shape Categories (186 total)

### 1. Basic Shapes (34 shapes)
Core geometric shapes commonly used in presentations:
- `rect`, `roundRect`, `ellipse`, `triangle`, `rtTriangle`
- `parallelogram`, `trapezoid`, `nonIsoscelesTrapezoid`, `diamond`
- `pentagon`, `hexagon`, `heptagon`, `octagon`, `decagon`, `dodecagon`
- `pie`, `pieWedge`, `chord`, `teardrop`, `frame`, `halfFrame`
- `corner`, `diagStripe`, `plus`, `plaque`, `can`, `cube`, `bevel`
- `donut`, `noSmoking`, `blockArc`, `arc`, `line`, `lineInv`

### 2. Stars & Banners (20 shapes)
Decorative shapes for emphasis:
- Stars: `star4`, `star5`, `star6`, `star7`, `star8`, `star10`, `star12`, `star16`, `star24`, `star32`
- Seals: `irregularSeal1`, `irregularSeal2`
- Ribbons: `ribbon`, `ribbon2`, `ellipseRibbon`, `ellipseRibbon2`
- Scrolls: `verticalScroll`, `horizontalScroll`
- Waves: `wave`, `doubleWave`

### 3. Arrows (21 shapes)
Directional indicators:
- Basic: `rightArrow`, `leftArrow`, `downArrow`, `leftRightArrow`, `upDownArrow`, `quadArrow`
- Combined: `leftRightUpArrow`, `leftUpArrow`
- Bent: `bentArrow`, `bentUpArrow`, `uturnArrow`
- Curved: `curvedRightArrow`, `curvedLeftArrow`, `curvedUpArrow`, `curvedDownArrow`
- Circular: `circularArrow`, `leftCircularArrow`, `leftRightCircularArrow`
- Special: `swooshArrow`, `notchedRightArrow`, `stripedRightArrow`

### 4. Callouts (23 shapes)
Speech bubbles and annotation shapes:
- Wedge callouts: `wedgeRectCallout`, `wedgeRoundRectCallout`, `wedgeEllipseCallout`
- Cloud: `cloudCallout`
- Border callouts: `borderCallout1`, `borderCallout2`, `borderCallout3`
- Accent border: `accentBorderCallout1`, `accentBorderCallout2`, `accentBorderCallout3`
- Basic callouts: `callout1`, `callout2`, `callout3`
- Accent callouts: `accentCallout1`, `accentCallout2`, `accentCallout3`
- Arrow callouts: `rightArrowCallout`, `leftArrowCallout`, `upArrowCallout`, `downArrowCallout`, `leftRightArrowCallout`, `upDownArrowCallout`, `quadArrowCallout`

### 5. Connectors (9 shapes)
Lines for connecting shapes:
- Straight: `straightConnector1`
- Bent: `bentConnector2`, `bentConnector3`, `bentConnector4`, `bentConnector5`
- Curved: `curvedConnector2`, `curvedConnector3`, `curvedConnector4`, `curvedConnector5`

### 6. Flowchart Shapes (29 shapes)
Standard flowchart symbols:
- Process: `flowChartProcess`, `flowChartAlternateProcess`, `flowChartPredefinedProcess`
- Decision: `flowChartDecision`
- Data: `flowChartInputOutput`, `flowChartDocument`, `flowChartMultidocument`
- Storage: `flowChartInternalStorage`, `flowChartOfflineStorage`, `flowChartOnlineStorage`
- Legacy storage: `flowChartMagneticTape`, `flowChartMagneticDisk`, `flowChartMagneticDrum`, `flowChartPunchedCard`, `flowChartPunchedTape`
- Operations: `flowChartManualInput`, `flowChartManualOperation`, `flowChartPreparation`
- Connectors: `flowChartConnector`, `flowChartOffpageConnector`
- Logic: `flowChartOr`, `flowChartSummingJunction`, `flowChartCollate`, `flowChartSort`, `flowChartExtract`, `flowChartMerge`
- Other: `flowChartTerminator`, `flowChartDisplay`, `flowChartDelay`

### 7. Action Buttons (12 shapes)
Interactive button shapes:
- `actionButtonBlank`, `actionButtonHome`, `actionButtonHelp`
- `actionButtonInformation`, `actionButtonForwardNext`, `actionButtonBackPrevious`
- `actionButtonEnd`, `actionButtonBeginning`, `actionButtonReturn`
- `actionButtonDocument`, `actionButtonSound`, `actionButtonMovie`

### 8. Math Symbols (6 shapes)
Mathematical operators:
- `mathPlus`, `mathMinus`, `mathMultiply`, `mathDivide`, `mathEqual`, `mathNotEqual`

### 9. Special Shapes (15 shapes)
Decorative and symbolic shapes:
- Symbols: `heart`, `lightningBolt`, `sun`, `moon`, `smileyFace`, `cloud`
- Mechanical: `gear6`, `gear9`
- Brackets: `leftBracket`, `rightBracket`, `leftBrace`, `rightBrace`, `bracketPair`, `bracePair`
- Other: `leftRightRibbon`

### 10. Modified Rectangles (7 shapes)
Rectangle variations:
- Rounded corners: `round1Rect`, `round2DiagRect`, `round2SameRect`
- Snipped corners: `snip1Rect`, `snip2DiagRect`, `snip2SameRect`
- Combined: `snipRoundRect`

### 11. Tabs & Charts (6 shapes)
Tab and chart-related shapes:
- Tabs: `cornerTabs`, `squareTabs`, `plaqueTabs`
- Charts: `chartX`, `chartStar`, `chartPlus`

### 12. Other Shapes (4 shapes)
Miscellaneous shapes:
- `foldedCorner`, `chevron`, `homePlate`, `funnel`

## Implementation Priority

Based on usage in sample files and common presentation needs:

### Phase 1 - Essential (Currently Implemented)
- `rect` - Rectangle
- `roundRect` - Rounded Rectangle
- `ellipse` - Ellipse/Circle
- `star5` - 5-Point Star

### Phase 2 - High Priority
- Other basic shapes: `triangle`, `diamond`, `pentagon`, `hexagon`
- Basic arrows: `rightArrow`, `leftArrow`, `upArrow`, `downArrow`
- Connectors: `straightConnector1`, `bentConnector2`, `curvedConnector2`

### Phase 3 - Medium Priority
- More stars: `star4`, `star6`, `star8`
- Callouts: `wedgeRectCallout`, `cloudCallout`
- Special shapes: `heart`, `sun`, `moon`

### Phase 4 - Low Priority
- Flowchart shapes
- Action buttons
- Complex arrows and ribbons
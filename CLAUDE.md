# Project Guidelines

When working on PPTX utility code for Swift, we prefer to discuss what to write in text before writing any code.

## Current Focus: Slide Rendering Feature (Implemented)

We have successfully implemented basic slide rendering capabilities to display PPTX slides as native iOS/macOS views. See docs/RENDERING_PLAN.md for implementation status and future enhancements.

### Testing Strategy Decision

After researching testing options (see docs/RENDERING_TEST_STRATEGY.md), here are the available tools for generating reference images:

1. **LibreOffice** (Recommended)
   - Free and open source
   - Command: `soffice --headless --convert-to pdf file.pptx`
   - Then use ImageMagick: `convert -density 300 file.pdf slide-%d.png`

2. **Apache POI PPTX2PNG**
   - Java-based, cross-platform
   - Good for CI/CD environments
   - Command: `java -cp poi.jar org.apache.poi.xslf.util.PPTX2PNG file.pptx`

3. **Manual Export**
   - PowerPoint on Mac can export to images
   - Keynote can also open PPTX and export

For image comparison, we can use:
- ImageMagick `compare` command for pixel differences
- Vision framework for perceptual similarity
- Custom Swift code for structural similarity

### Key Decisions Made:
1. Use LibreOffice as primary reference generator (when available)
2. Set 90% similarity threshold for test passing
3. Focus on visual regression testing, not pixel-perfect matching

### Decisions Implemented:
1. ✅ Platform API design: Both UIKit/AppKit native views and SwiftUI wrapper
2. ✅ Rendering quality levels: Low, Balanced, High with configurable trade-offs
3. ✅ V1 elements: Basic shapes (rectangle, ellipse, arrow, star), text with font mapping, placeholder images
4. ✅ Memory management: On-demand rendering with view-level caching

### Next Steps:
1. Implement full XML parsing for actual slide content (currently using placeholder data)
2. Add support for gradients, shadows, and other effects
3. Implement image extraction from PPTX archives
4. Add more shape types and complex path support
5. Improve text layout engine for better alignment and flow
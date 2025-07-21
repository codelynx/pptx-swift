# PPTX Rendering Test Strategy

## Overview

Testing slide rendering accuracy requires comparing our output against reference implementations. This document outlines tools, methods, and strategies for validating our rendering implementation.

## Reference Rendering Tools

### 1. LibreOffice Command Line

LibreOffice can convert PPTX to images via CLI, providing a good open-source reference.

```bash
# Install on macOS
brew install --cask libreoffice

# Convert slide to PNG
soffice --headless --convert-to png:"draw_png_Export" --outdir ./output presentation.pptx

# Convert specific slide to PNG (requires macro)
soffice --headless --convert-to pdf presentation.pptx
# Then use ImageMagick to extract pages
```

### 2. unoconv (Universal Office Converter)

Built on LibreOffice but easier to use:

```bash
# Install
brew install unoconv

# Convert to PNG
unoconv -f png presentation.pptx

# Convert to PDF then extract pages
unoconv -f pdf presentation.pptx
convert -density 300 presentation.pdf slide-%d.png
```

### 3. Apache POI with PPTX2PNG

Java-based tool specifically for PPTX rendering:

```bash
# Using Apache POI's PPTX2PNG
java -cp poi-scratchpad.jar:poi-ooxml.jar:poi.jar \
     org.apache.poi.xslf.util.PPTX2PNG \
     -scale 2.0 presentation.pptx

# Outputs: slide-1.png, slide-2.png, etc.
```

### 4. Aspose.Slides CLI

Commercial but offers free tier:

```bash
# Using Aspose.Slides Cloud CLI
aspose slides convert --input presentation.pptx \
                     --format png \
                     --output-path ./output
```

### 5. Microsoft PowerPoint Automation (macOS)

Using AppleScript or PowerPoint's automation:

```applescript
-- SaveAsPNG.applescript
on run argv
    set inputFile to item 1 of argv
    set outputDir to item 2 of argv
    
    tell application "Microsoft PowerPoint"
        open inputFile
        set thePresentation to active presentation
        save thePresentation in outputDir as save as PNG
        close thePresentation
    end tell
end run

# Run with:
osascript SaveAsPNG.applescript presentation.pptx ./output/
```

### 6. Python-pptx with Pillow

For programmatic reference generation:

```python
# render_reference.py
from pptx import Presentation
from pptx.util import Inches
import io
from PIL import Image

# Note: python-pptx doesn't directly render,
# but can be combined with other tools

# Better option: use python-pptx to extract content
# and render with matplotlib or similar
```

## Recommended Test Setup

### Primary Reference: LibreOffice

```bash
#!/bin/bash
# generate_references.sh

PPTX_FILE=$1
OUTPUT_DIR=$2

# Convert to PDF first (better quality)
soffice --headless --convert-to pdf --outdir /tmp "$PPTX_FILE"

# Extract slides as PNG
PDF_FILE="/tmp/$(basename "$PPTX_FILE" .pptx).pdf"
convert -density 300 "$PDF_FILE" "$OUTPUT_DIR/slide-%d.png"

# Clean up
rm "$PDF_FILE"
```

### Secondary Reference: Apache POI

```bash
#!/bin/bash
# generate_poi_references.sh

# Download POI if needed
if [ ! -f "poi-bin-5.2.4/poi-5.2.4.jar" ]; then
    wget https://dlcdn.apache.org/poi/release/bin/poi-bin-5.2.4.tar.gz
    tar -xzf poi-bin-5.2.4.tar.gz
fi

# Run PPTX2PNG
java -cp "poi-bin-5.2.4/*:poi-bin-5.2.4/lib/*:poi-bin-5.2.4/ooxml-lib/*" \
     org.apache.poi.xslf.util.PPTX2PNG \
     -scale 2.0 -format png "$1"
```

## Image Comparison Tools

### 1. ImageMagick Compare

```bash
# Pixel-by-pixel comparison
compare -metric RMSE reference.png rendered.png diff.png

# Perceptual comparison
compare -metric PHASH reference.png rendered.png diff.png

# Fuzzy comparison (allows small differences)
compare -fuzz 5% reference.png rendered.png diff.png
```

### 2. Swift Image Comparison

```swift
import Vision
import CoreImage

func compareImages(_ image1: CGImage, _ image2: CGImage) -> Float {
    // Using Vision framework for perceptual comparison
    let request = VNFeaturePrintObservationRequest()
    
    // Process both images
    let handler1 = VNImageRequestHandler(cgImage: image1)
    let handler2 = VNImageRequestHandler(cgImage: image2)
    
    try? handler1.perform([request])
    let observation1 = request.results?.first as? VNFeaturePrintObservation
    
    try? handler2.perform([request])
    let observation2 = request.results?.first as? VNFeaturePrintObservation
    
    // Calculate distance
    var distance: Float = 0
    try? observation1?.computeDistance(&distance, to: observation2!)
    
    return 1.0 - distance // Convert to similarity score
}
```

### 3. OpenCV for Structural Similarity

```python
# compare_slides.py
import cv2
from skimage.metrics import structural_similarity as ssim

def compare_slides(ref_path, test_path):
    ref = cv2.imread(ref_path)
    test = cv2.imread(test_path)
    
    # Convert to grayscale
    ref_gray = cv2.cvtColor(ref, cv2.COLOR_BGR2GRAY)
    test_gray = cv2.cvtColor(test, cv2.COLOR_BGR2GRAY)
    
    # Calculate SSIM
    score, diff = ssim(ref_gray, test_gray, full=True)
    
    return score, diff
```

## Test Framework Integration

### XCTest with Snapshot Testing

```swift
import XCTest
import SnapshotTesting

class SlideRenderingTests: XCTestCase {
    func testSlideRendering() throws {
        // Render slide
        let document = try PPTXDocument(filePath: "test.pptx")
        let slideView = PPTXSlideView(document: document, slideIndex: 1)
        
        // Compare with reference
        assertSnapshot(matching: slideView, as: .image(precision: 0.95))
    }
}
```

### Custom Test Runner

```swift
// RenderingTestRunner.swift
import Foundation

struct RenderingTest {
    let pptxFile: String
    let slideIndex: Int
    let referenceTool: ReferenceTool
    let acceptableThreshold: Float = 0.90
}

enum ReferenceTool {
    case libreOffice
    case apachePOI
    case powerpoint
}

class RenderingTestRunner {
    func runTests(_ tests: [RenderingTest]) -> TestResults {
        var results = TestResults()
        
        for test in tests {
            // 1. Generate reference image
            let referenceImage = generateReference(test)
            
            // 2. Render with our implementation
            let renderedImage = renderSlide(test)
            
            // 3. Compare images
            let similarity = compareImages(referenceImage, renderedImage)
            
            // 4. Record result
            results.record(test: test, similarity: similarity)
        }
        
        return results
    }
}
```

## Test Data Sets

### 1. Basic Elements Test Suite
```
test-basic/
├── shapes-basic.pptx      # Rectangle, circle, triangle
├── text-simple.pptx       # Plain text, various sizes
├── colors-solid.pptx      # Solid fills, no gradients
└── layout-standard.pptx   # Standard layouts
```

### 2. Intermediate Test Suite
```
test-intermediate/
├── shapes-complex.pptx    # Stars, arrows, custom paths
├── text-formatted.pptx    # Bold, italic, colors
├── images-embedded.pptx   # JPEG, PNG images
└── gradients-linear.pptx  # Linear gradients
```

### 3. Advanced Test Suite
```
test-advanced/
├── charts-basic.pptx      # Bar, pie charts
├── tables-styled.pptx     # Formatted tables
├── smartart-simple.pptx   # Basic SmartArt
└── effects-shadows.pptx   # Shadows, reflections
```

### 4. Real-World Test Suite
Sample presentations from:
- Business templates
- Educational content
- Marketing materials
- Technical documentation

## CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Rendering Tests

on: [push, pull_request]

jobs:
  rendering-tests:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install LibreOffice
      run: brew install --cask libreoffice
    
    - name: Generate References
      run: |
        ./scripts/generate_references.sh tests/fixtures output/references
    
    - name: Run Rendering Tests
      run: |
        swift test --filter RenderingTests
    
    - name: Upload Diff Images
      if: failure()
      uses: actions/upload-artifact@v3
      with:
        name: rendering-diffs
        path: output/diffs/
```

## Visual Regression Testing

### 1. Baseline Management

```bash
# Directory structure
tests/
├── visual-baselines/
│   ├── shapes-basic/
│   │   ├── slide-1.png
│   │   └── slide-1.meta.json
│   └── approved/
│       └── BASELINE_VERSION
└── visual-output/
    └── current/
```

### 2. Approval Workflow

```swift
// VisualTestApprover.swift
class VisualTestApprover {
    func reviewFailures() {
        // 1. Show side-by-side comparison
        // 2. Allow approve/reject
        // 3. Update baselines if approved
    }
}
```

## Performance Benchmarking

```swift
// RenderingBenchmark.swift
import XCTest

class RenderingBenchmarks: XCTestCase {
    func testRenderingPerformance() {
        let document = try! PPTXDocument(filePath: "complex.pptx")
        
        measure {
            for i in 1...10 {
                let view = PPTXSlideView(document: document, slideIndex: i)
                _ = view.renderToImage()
            }
        }
    }
}
```

## Recommendations

1. **Primary Testing Strategy**
   - Use LibreOffice as primary reference (free, cross-platform)
   - ImageMagick for comparison with configurable thresholds
   - Snapshot testing for regression prevention

2. **Test Coverage Goals**
   - 100% of basic shapes and text
   - 90% of common slide layouts
   - 80% similarity threshold for complex slides

3. **Automation**
   - Generate references automatically in CI
   - Flag visual regressions in PRs
   - Maintain approved baseline images

4. **Manual Testing**
   - Visual review for aesthetic issues
   - Performance testing on real devices
   - Memory profiling with complex presentations
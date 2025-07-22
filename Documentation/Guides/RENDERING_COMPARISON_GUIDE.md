# PPTX Rendering and Comparison Guide

## Overview

This guide explains how to render PPTX slides using PPTXKit and compare the output with PowerPoint-generated PDFs to evaluate rendering accuracy.

## Prerequisites

- Xcode with Swift 5.9+
- PowerPoint or Keynote (for PDF generation)
- Sample PPTX files for testing

## Building the CLI Tool

First, build the `pptx-analyzer` CLI tool:

```bash
cd /path/to/pptx-swift
swift build -c release
```

Or for development builds:

```bash
swift build
```

## CLI Usage

### Basic Slide Rendering

Render a single slide to PNG:

```bash
# Development build
swift run pptx-analyzer render presentation.pptx --slide 1 --output slide1.png

# Release build (faster)
.build/release/pptx-analyzer render presentation.pptx --slide 1 --output slide1.png
```

### Command Options

```bash
swift run pptx-analyzer render <pptx-file> [options]

Options:
  --slide <number>     Slide number to render (1-based, default: 1)
  --output <path>      Output PNG file path (default: slide.png)
  --width <pixels>     Output width in pixels (default: 960)
  --height <pixels>    Output height in pixels (default: 720)
  --scale <factor>     Scaling factor (default: 2.0 for retina)
```

### Batch Rendering

Render all slides in a presentation:

```bash
# Create output directory
mkdir output

# Render each slide (adjust slide count as needed)
for i in {1..6}; do
  swift run pptx-analyzer render sample.pptx --slide $i --output "output/slide_${i}.png"
done
```

## Generating Reference PDFs from PowerPoint

### Option 1: PowerPoint (Windows/Mac)

1. Open your PPTX file in PowerPoint
2. Go to **File** → **Export** → **Create PDF/XPS**
3. Choose quality settings:
   - **Optimize for**: Print (300 DPI)
   - **What to publish**: All slides
   - **Include**: Slides only
4. Save as `reference.pdf`

### Option 2: Keynote (Mac)

1. Open PPTX file in Keynote
2. Go to **File** → **Export To** → **PDF**
3. Choose **Image Quality**: Best
4. Save as `reference.pdf`

### Option 3: LibreOffice (Cross-platform, Free)

```bash
# Install LibreOffice (if not already installed)
# macOS: brew install --cask libreoffice
# Ubuntu: sudo apt install libreoffice

# Convert PPTX to PDF
soffice --headless --convert-to pdf presentation.pptx
```

## Converting PDF to Images for Comparison

### Using ImageMagick

Install ImageMagick:

```bash
# macOS
brew install imagemagick

# Ubuntu
sudo apt install imagemagick

# Windows (with Chocolatey)
choco install imagemagick
```

Convert PDF slides to PNG images:

```bash
# Convert all pages to individual PNGs
convert -density 300 reference.pdf reference_slide_%d.png

# Convert with specific dimensions (matching CLI output)
convert -density 300 -resize 960x720 reference.pdf reference_slide_%d.png

# For better quality matching
convert -density 300 -background white -alpha remove reference.pdf reference_slide_%d.png
```

### Using Preview (Mac)

1. Open PDF in Preview
2. Select all pages (Cmd+A)
3. Go to **File** → **Export Selected Images**
4. Choose PNG format
5. Set resolution to 300 DPI

## Comparison Workflow

### Step 1: Prepare Test Files

```bash
# Create comparison directory
mkdir slide_comparison
cd slide_comparison

# Copy your PPTX file
cp ~/Documents/presentation.pptx sample.pptx
```

### Step 2: Generate Reference Images

```bash
# Generate PDF reference
soffice --headless --convert-to pdf sample.pptx

# Convert PDF to images
convert -density 300 sample.pdf reference_slide_%d.png

# Rename to match our numbering (ImageMagick starts at 0)
for i in reference_slide_*.png; do
  num=$(echo $i | grep -o '[0-9]*')
  new_num=$((num + 1))
  mv "$i" "reference_slide_${new_num}.png"
done
```

### Step 3: Generate PPTXKit Renderings

```bash
# Render slides with PPTXKit
for i in {1..6}; do
  swift run pptx-analyzer render sample.pptx --slide $i --output "pptxkit_slide_${i}.png"
done
```

### Step 4: Visual Comparison

Create side-by-side comparisons:

```bash
# Install ImageMagick montage tool (included with ImageMagick)
for i in {1..6}; do
  montage "reference_slide_${i}.png" "pptxkit_slide_${i}.png" \
    -geometry +10+10 -background white \
    "comparison_slide_${i}.png"
done
```

### Step 5: Automated Difference Detection

```bash
# Generate difference images highlighting discrepancies
for i in {1..6}; do
  compare "reference_slide_${i}.png" "pptxkit_slide_${i}.png" \
    -highlight-color red "diff_slide_${i}.png"
done
```

## Example Script

Save as `compare_rendering.sh`:

```bash
#!/bin/bash

# Configuration
PPTX_FILE="$1"
SLIDE_COUNT="$2"
OUTPUT_DIR="comparison_$(date +%Y%m%d_%H%M%S)"

if [ -z "$PPTX_FILE" ] || [ -z "$SLIDE_COUNT" ]; then
  echo "Usage: $0 <pptx-file> <slide-count>"
  echo "Example: $0 presentation.pptx 6"
  exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

echo "🔄 Generating reference PDF..."
soffice --headless --convert-to pdf "../$PPTX_FILE"

BASENAME=$(basename "$PPTX_FILE" .pptx)
PDF_FILE="${BASENAME}.pdf"

echo "🖼️  Converting PDF to images..."
convert -density 300 -background white -alpha remove \
  "$PDF_FILE" "reference_slide_%d.png"

# Rename to 1-based indexing
for file in reference_slide_*.png; do
  if [[ $file =~ reference_slide_([0-9]+)\.png ]]; then
    old_num=${BASH_REMATCH[1]}
    new_num=$((old_num + 1))
    mv "$file" "reference_slide_${new_num}.png"
  fi
done

echo "⚡ Rendering slides with PPTXKit..."
for ((i=1; i<=SLIDE_COUNT; i++)); do
  echo "  Rendering slide $i..."
  swift run pptx-analyzer render "../$PPTX_FILE" \
    --slide $i --output "pptxkit_slide_${i}.png"
done

echo "📊 Creating comparisons..."
for ((i=1; i<=SLIDE_COUNT; i++)); do
  if [ -f "reference_slide_${i}.png" ] && [ -f "pptxkit_slide_${i}.png" ]; then
    # Side-by-side comparison
    montage "reference_slide_${i}.png" "pptxkit_slide_${i}.png" \
      -geometry +10+10 -background white -title "Slide $i: Reference vs PPTXKit" \
      "comparison_slide_${i}.png"
    
    # Difference highlighting
    compare "reference_slide_${i}.png" "pptxkit_slide_${i}.png" \
      -highlight-color red "diff_slide_${i}.png" 2>/dev/null || true
  fi
done

echo "✅ Comparison complete! Results in: $OUTPUT_DIR"
echo "📁 Files generated:"
echo "   - reference_slide_N.png (PowerPoint reference)"
echo "   - pptxkit_slide_N.png (PPTXKit rendering)"
echo "   - comparison_slide_N.png (side-by-side)"
echo "   - diff_slide_N.png (differences highlighted)"
```

Make it executable and run:

```bash
chmod +x compare_rendering.sh
./compare_rendering.sh presentation.pptx 6
```

## Programmatic Rendering (Swift Code)

### Basic Usage

```swift
import PPTXKit

do {
    // Load presentation
    let document = try PPTXDocument(filePath: "presentation.pptx")
    
    // Get slide count
    let slideCount = document.slides.count
    
    // Create slide renderer
    let renderer = SlideRenderer(
        quality: .high,
        scale: 2.0
    )
    
    // Render specific slide
    let slide = document.slides[0] // First slide
    let image = try renderer.renderSlide(slide, size: CGSize(width: 960, height: 720))
    
    // Save to file
    let data = image.pngData()
    try data?.write(to: URL(fileURLWithPath: "slide.png"))
    
} catch {
    print("Error: \(error)")
}
```

### Batch Rendering

```swift
import PPTXKit
import Foundation

func renderAllSlides(from pptxPath: String, outputDir: String) throws {
    let document = try PPTXDocument(filePath: pptxPath)
    let renderer = SlideRenderer(quality: .high, scale: 2.0)
    
    // Create output directory
    try FileManager.default.createDirectory(
        atPath: outputDir,
        withIntermediateDirectories: true
    )
    
    for (index, slide) in document.slides.enumerated() {
        let slideNumber = index + 1
        print("Rendering slide \(slideNumber)...")
        
        let image = try renderer.renderSlide(
            slide,
            size: CGSize(width: 960, height: 720)
        )
        
        let outputPath = "\(outputDir)/slide_\(slideNumber).png"
        try image.pngData()?.write(to: URL(fileURLWithPath: outputPath))
    }
}

// Usage
try renderAllSlides(from: "presentation.pptx", outputDir: "output")
```

## Quality Assessment Tips

### Visual Inspection Checklist

1. **Text Rendering**:
   - Font selection and sizing
   - Text alignment and positioning
   - Bold, italic, underline formatting
   - Text colors and theme colors

2. **Shape Rendering**:
   - Shape geometry and positioning
   - Fill colors and gradients
   - Stroke/border colors and widths
   - Custom shapes (stars, arrows, polygons)

3. **Layout Accuracy**:
   - Element positioning and sizing
   - Slide background colors/images
   - Overall composition and spacing

4. **Color Accuracy**:
   - Theme color application
   - Gradient color transitions
   - Color consistency across elements

### Common Discrepancies

1. **Font Differences**: System font mapping may cause slight variations
2. **Anti-aliasing**: Different rendering engines may produce edge differences  
3. **Color Profiles**: RGB interpretation may vary slightly
4. **Precision**: Floating-point calculations may cause minor positioning differences

### Acceptable Tolerance

- **Text**: Minor font substitution is acceptable
- **Colors**: RGB differences within 5% are typically acceptable
- **Positioning**: Pixel-level differences are acceptable for elements
- **Shapes**: Geometric accuracy should be high (>95% similarity)

## Troubleshooting

### Common Issues

1. **"PPTX file not found"**:
   - Ensure file path is correct
   - Use absolute paths if needed

2. **"No slide at index"**:
   - Check slide count with: `swift run pptx-analyzer info file.pptx`
   - Slides are 1-based indexed

3. **LibreOffice conversion fails**:
   - Ensure LibreOffice is properly installed
   - Try running LibreOffice GUI first to initialize

4. **ImageMagick permission errors**:
   - Check ImageMagick security policy: `/etc/ImageMagick-*/policy.xml`
   - May need to modify PDF handling permissions

### Performance Tips

1. **Use release builds** for faster rendering:
   ```bash
   swift build -c release
   .build/release/pptx-analyzer render file.pptx --slide 1
   ```

2. **Batch process** multiple slides efficiently:
   ```bash
   # Parallel processing (adjust -P value based on CPU cores)
   seq 1 10 | xargs -I {} -P 4 swift run pptx-analyzer render file.pptx --slide {} --output slide_{}.png
   ```

3. **Cache builds** by keeping Swift compiler output:
   ```bash
   # Build once, run many times
   swift build -c release
   for i in {1..10}; do
     .build/release/pptx-analyzer render file.pptx --slide $i --output slide_$i.png
   done
   ```

This guide provides comprehensive instructions for rendering PPTX slides with PPTXKit and comparing them against PowerPoint references to evaluate rendering accuracy and identify areas for improvement.
# PPTXKit CLI Usage Guide

## Quick Start

### Build the CLI Tool

```bash
# Development build
swift build

# Release build (faster)
swift build -c release
```

### Basic Commands

```bash
# Get presentation summary
swift run pptx-analyzer summary presentation.pptx

# Render single slide
swift run pptx-analyzer render presentation.pptx --slide 1 --output slide1.png

# Use release build for better performance
.build/release/pptx-analyzer render presentation.pptx --slide 1 --output slide1.png
```

## Command Reference

### `summary` - Presentation Information

Display presentation metadata and slide count:

```bash
swift run pptx-analyzer summary <pptx-file>
```

**Example Output:**
```
Successfully loaded theme: Office
- Accent1 color: #4F81BD
Presentation Summary
===================
File: sample.pptx
Title: Widescreen
Author: Kazunari Yoshikawa

Statistics:
-----------
Total slides: 6
Media assets: 1

Metadata:
---------
Created: Jul 22, 2025 at 8:35
Modified: Jul 22, 2025 at 9:04
Application: Microsoft Macintosh PowerPoint (v16.0000)
File size: 568 KB
```

### `render` - Slide Rendering

Render slides to PNG images:

```bash
swift run pptx-analyzer render <pptx-file> [options]
```

**Options:**
- `--slide <number>` - Slide number to render (1-based, default: 1)
- `--output <path>` - Output PNG file path (default: slide.png)  
- `--width <pixels>` - Output width in pixels (default: 960)
- `--height <pixels>` - Output height in pixels (default: 720)
- `--scale <factor>` - Scaling factor (default: 2.0 for retina)

**Examples:**
```bash
# Render slide 3 with default settings
swift run pptx-analyzer render presentation.pptx --slide 3

# Custom output path and size
swift run pptx-analyzer render presentation.pptx \
  --slide 1 --output "renders/title_slide.png" \
  --width 1920 --height 1080

# High-DPI rendering
swift run pptx-analyzer render presentation.pptx \
  --slide 1 --scale 3.0 --output slide1@3x.png
```

## Common Workflows

### 1. Quick Presentation Preview

```bash
# Get slide count
SLIDE_COUNT=$(swift run pptx-analyzer summary presentation.pptx | grep "Total slides:" | awk '{print $3}')

# Render first few slides
for i in {1..3}; do
  swift run pptx-analyzer render presentation.pptx --slide $i --output "preview_slide_$i.png"
done
```

### 2. Batch Render All Slides

```bash
#!/bin/bash
PPTX_FILE="$1"
OUTPUT_DIR="slides"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get slide count
SLIDE_COUNT=$(swift run pptx-analyzer summary "$PPTX_FILE" | grep "Total slides:" | awk '{print $3}')

# Render all slides
for ((i=1; i<=SLIDE_COUNT; i++)); do
  echo "Rendering slide $i of $SLIDE_COUNT..."
  swift run pptx-analyzer render "$PPTX_FILE" \
    --slide $i --output "$OUTPUT_DIR/slide_$i.png"
done

echo "✅ Rendered $SLIDE_COUNT slides to $OUTPUT_DIR/"
```

### 3. High-Resolution Export

```bash
# 4K rendering for print quality
swift run pptx-analyzer render presentation.pptx \
  --slide 1 --width 3840 --height 2160 --scale 1.0 --output slide1_4k.png

# Multiple resolutions
for size in "960x720" "1920x1440" "3840x2880"; do
  IFS='x' read -r width height <<< "$size"
  swift run pptx-analyzer render presentation.pptx \
    --slide 1 --width $width --height $height --output "slide1_${size}.png"
done
```

### 4. Performance Benchmarking

```bash
# Time rendering performance
time swift run pptx-analyzer render large_presentation.pptx --slide 1

# Benchmark multiple slides
for i in {1..10}; do
  echo "Timing slide $i:"
  time swift run pptx-analyzer render presentation.pptx --slide $i --output "/dev/null"
done
```

### 5. Parallel Processing

```bash
# Render slides in parallel (adjust -P based on CPU cores)
seq 1 10 | xargs -I {} -P 4 bash -c '
  swift run pptx-analyzer render presentation.pptx --slide {} --output slide_{}.png
  echo "Completed slide {}"
'
```

## Development vs Release Builds

### Development Build
- **Command**: `swift run pptx-analyzer`
- **Use Case**: Development, debugging, quick tests
- **Performance**: Slower due to debug information
- **Build Time**: Faster incremental builds

### Release Build  
- **Command**: `.build/release/pptx-analyzer`
- **Use Case**: Production rendering, batch processing
- **Performance**: ~3-5x faster rendering
- **Build Time**: Slower initial build

```bash
# Build once for multiple uses
swift build -c release

# Then use release binary directly
.build/release/pptx-analyzer render presentation.pptx --slide 1
```

## Output Examples

### Successful Rendering
```
Successfully loaded theme: Office
- Accent1 color: #4F81BD
Rendering slide 1 of 6...
DEBUG: Parsing XML data of size: 8542 bytes
DEBUG: Parsed 15 shapes from XML
✅ Rendered slide saved to: slide1.png
```

### Error Examples
```
# File not found
❌ Error: PPTX file not found: missing.pptx

# Invalid slide number  
❌ Error: No slide found at index 10. Presentation has 6 slides.

# Permission error
❌ Error: Unable to write to output file: /protected/slide.png
```

## Tips and Best Practices

### 1. File Paths
- Use absolute paths to avoid confusion
- Quote paths with spaces: `"My Presentation.pptx"`
- Check file exists before rendering

### 2. Performance Optimization
- Use release builds for batch processing
- Consider parallel processing for multiple slides
- Cache Swift build artifacts between runs

### 3. Output Management
- Create organized output directories
- Use meaningful filenames with slide numbers
- Consider date/time stamps for multiple runs

### 4. Quality Settings
- Default scale (2.0) works well for screen display
- Use scale 1.0 with high width/height for print quality
- Test different scales to find optimal balance

### 5. Debugging Issues
- Check presentation info first: `swift run pptx-analyzer summary file.pptx`
- Render single slides before batch processing
- Compare output with PowerPoint-exported images

## Integration Examples

### Shell Script Integration
```bash
#!/bin/bash
render_presentation() {
  local pptx_file="$1"
  local output_dir="$2"
  
  mkdir -p "$output_dir"
  
  local slide_count=$(swift run pptx-analyzer summary "$pptx_file" | 
                     grep "Total slides:" | awk '{print $3}')
  
  for ((i=1; i<=slide_count; i++)); do
    .build/release/pptx-analyzer render "$pptx_file" \
      --slide $i --output "$output_dir/slide_$i.png"
  done
}

render_presentation "presentation.pptx" "output"
```

### Makefile Integration
```makefile
PPTX_FILE ?= presentation.pptx
OUTPUT_DIR ?= slides
SLIDES ?= $(shell swift run pptx-analyzer summary $(PPTX_FILE) | grep "Total slides:" | awk '{print $$3}')

.PHONY: build render clean

build:
	swift build -c release

render: build
	mkdir -p $(OUTPUT_DIR)
	$(foreach i,$(shell seq 1 $(SLIDES)), \
		.build/release/pptx-analyzer render $(PPTX_FILE) \
			--slide $(i) --output $(OUTPUT_DIR)/slide_$(i).png;)

clean:
	rm -rf $(OUTPUT_DIR) .build
```

This CLI usage guide provides comprehensive examples for using PPTXKit's command-line interface effectively.
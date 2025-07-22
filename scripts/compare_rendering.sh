#!/bin/bash

# PPTXKit Rendering Comparison Script
# Compares PPTXKit rendering output with PowerPoint-generated PDF reference

set -e  # Exit on any error

# Configuration
PPTX_FILE="$1"
SLIDE_COUNT="$2"
OUTPUT_DIR="comparison_$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_usage() {
    echo "Usage: $0 <pptx-file> <slide-count>"
    echo ""
    echo "Example: $0 presentation.pptx 6"
    echo ""
    echo "Requirements:"
    echo "  - LibreOffice (for PDF conversion)"
    echo "  - ImageMagick (for image processing)"
    echo "  - PPTXKit CLI tool (built with 'swift build')"
    echo ""
    echo "This script will:"
    echo "  1. Convert PPTX to PDF using LibreOffice"
    echo "  2. Extract PDF pages as PNG images"
    echo "  3. Render slides using PPTXKit CLI"
    echo "  4. Create side-by-side comparisons"
    echo "  5. Generate difference highlighting"
}

check_dependencies() {
    local missing_deps=()
    
    if ! command -v soffice >/dev/null 2>&1; then
        missing_deps+=("LibreOffice (soffice)")
    fi
    
    if ! command -v convert >/dev/null 2>&1; then
        missing_deps+=("ImageMagick (convert)")
    fi
    
    if ! command -v montage >/dev/null 2>&1; then
        missing_deps+=("ImageMagick (montage)")
    fi
    
    if ! command -v compare >/dev/null 2>&1; then
        missing_deps+=("ImageMagick (compare)")
    fi
    
    if [ ! -f ".build/debug/pptx-analyzer" ] && [ ! -f ".build/release/pptx-analyzer" ]; then
        missing_deps+=("PPTXKit CLI (run 'swift build')")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing dependencies:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo "   - $dep"
        done
        echo ""
        echo "Install missing dependencies and try again."
        exit 1
    fi
}

# Check arguments
if [ -z "$PPTX_FILE" ] || [ -z "$SLIDE_COUNT" ]; then
    print_usage
    exit 1
fi

# Verify file exists
if [ ! -f "$PPTX_FILE" ]; then
    echo -e "${RED}❌ Error: PPTX file not found: $PPTX_FILE${NC}"
    exit 1
fi

# Check dependencies
echo -e "${BLUE}🔍 Checking dependencies...${NC}"
check_dependencies
echo -e "${GREEN}✅ All dependencies found${NC}"

# Determine which CLI binary to use
CLI_BINARY=""
if [ -f ".build/release/pptx-analyzer" ]; then
    CLI_BINARY=".build/release/pptx-analyzer"
    echo -e "${GREEN}📦 Using release build for better performance${NC}"
elif [ -f ".build/debug/pptx-analyzer" ]; then
    CLI_BINARY="swift run pptx-analyzer"
    echo -e "${YELLOW}📦 Using debug build (consider 'swift build -c release' for speed)${NC}"
fi

# Create output directory
echo -e "${BLUE}📁 Creating output directory: $OUTPUT_DIR${NC}"
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# Step 1: Generate reference PDF
echo -e "${BLUE}🔄 Converting PPTX to PDF using LibreOffice...${NC}"
soffice --headless --convert-to pdf "../$PPTX_FILE"

BASENAME=$(basename "$PPTX_FILE" .pptx)
PDF_FILE="${BASENAME}.pdf"

if [ ! -f "$PDF_FILE" ]; then
    echo -e "${RED}❌ Error: PDF conversion failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ PDF created: $PDF_FILE${NC}"

# Step 2: Extract PDF pages as images
echo -e "${BLUE}🖼️  Extracting PDF pages to PNG images...${NC}"
convert -density 300 -background white -alpha remove \
  "$PDF_FILE" "reference_slide_%d.png"

# Rename to 1-based indexing (ImageMagick uses 0-based)
for file in reference_slide_*.png; do
  if [[ $file =~ reference_slide_([0-9]+)\.png ]]; then
    old_num=${BASH_REMATCH[1]}
    new_num=$((old_num + 1))
    mv "$file" "reference_slide_${new_num}.png"
    echo "  📄 Extracted reference slide $new_num"
  fi
done

# Step 3: Render slides with PPTXKit
echo -e "${BLUE}⚡ Rendering slides with PPTXKit...${NC}"
for ((i=1; i<=SLIDE_COUNT; i++)); do
  echo "  🎨 Rendering slide $i..."
  
  if [ "$CLI_BINARY" = "swift run pptx-analyzer" ]; then
    cd ..
    $CLI_BINARY render "$PPTX_FILE" --slide $i --output "$OUTPUT_DIR/pptxkit_slide_${i}.png"
    cd "$OUTPUT_DIR"
  else
    ../$CLI_BINARY render "../$PPTX_FILE" --slide $i --output "pptxkit_slide_${i}.png"
  fi
  
  if [ -f "pptxkit_slide_${i}.png" ]; then
    echo -e "    ${GREEN}✅ PPTXKit slide $i rendered${NC}"
  else
    echo -e "    ${RED}❌ PPTXKit slide $i failed${NC}"
  fi
done

# Step 4: Create comparisons
echo -e "${BLUE}📊 Creating side-by-side comparisons...${NC}"
for ((i=1; i<=SLIDE_COUNT; i++)); do
  if [ -f "reference_slide_${i}.png" ] && [ -f "pptxkit_slide_${i}.png" ]; then
    echo "  🔍 Comparing slide $i..."
    
    # Side-by-side comparison
    montage "reference_slide_${i}.png" "pptxkit_slide_${i}.png" \
      -geometry +10+10 -background white \
      -label "PowerPoint Reference" -label "PPTXKit Rendering" \
      "comparison_slide_${i}.png"
    
    echo -e "    ${GREEN}✅ Comparison image created${NC}"
    
    # Difference highlighting (suppress stderr as it's often just warnings)
    if compare "reference_slide_${i}.png" "pptxkit_slide_${i}.png" \
       -highlight-color red "diff_slide_${i}.png" 2>/dev/null; then
      echo -e "    ${GREEN}✅ Difference image created${NC}"
    else
      echo -e "    ${YELLOW}⚠️  Difference highlighting may have issues${NC}"
    fi
  else
    echo -e "  ${RED}❌ Missing files for slide $i comparison${NC}"
  fi
done

# Step 5: Generate summary
echo -e "${BLUE}📋 Generating comparison summary...${NC}"
cat > "README.md" << EOF
# Rendering Comparison Results

**Generated:** $(date)
**PPTX File:** $PPTX_FILE
**Slides:** $SLIDE_COUNT

## Files Generated

### Reference Images (PowerPoint → PDF → PNG)
$(for i in $(seq 1 $SLIDE_COUNT); do echo "- \`reference_slide_${i}.png\` - PowerPoint reference for slide $i"; done)

### PPTXKit Renderings
$(for i in $(seq 1 $SLIDE_COUNT); do echo "- \`pptxkit_slide_${i}.png\` - PPTXKit rendering of slide $i"; done)

### Comparisons
$(for i in $(seq 1 $SLIDE_COUNT); do echo "- \`comparison_slide_${i}.png\` - Side-by-side comparison of slide $i"; done)

### Difference Analysis
$(for i in $(seq 1 $SLIDE_COUNT); do echo "- \`diff_slide_${i}.png\` - Differences highlighted in red for slide $i"; done)

## How to Review

1. **Visual Comparison**: Open \`comparison_slide_N.png\` files to see side-by-side comparisons
2. **Difference Analysis**: Open \`diff_slide_N.png\` files to see highlighted differences
3. **Individual Review**: Compare \`reference_slide_N.png\` vs \`pptxkit_slide_N.png\` directly

## Quality Assessment

Look for these aspects:
- ✅ **Text rendering** - Font, size, positioning, formatting
- ✅ **Shape rendering** - Geometry, fills, strokes, gradients  
- ✅ **Layout accuracy** - Element positioning and sizing
- ✅ **Color fidelity** - Theme colors, gradients, fills
- ✅ **Overall composition** - Visual similarity to reference

Minor differences in font rendering and anti-aliasing are acceptable.
Focus on major layout, color, or shape discrepancies.
EOF

# Final summary
echo ""
echo -e "${GREEN}✅ Comparison complete!${NC}"
echo -e "${BLUE}📁 Results saved to: $OUTPUT_DIR${NC}"
echo ""
echo -e "${YELLOW}📊 Summary:${NC}"
echo "   - Reference images: reference_slide_N.png"
echo "   - PPTXKit renderings: pptxkit_slide_N.png"
echo "   - Side-by-side comparisons: comparison_slide_N.png"
echo "   - Difference analysis: diff_slide_N.png"
echo "   - Summary report: README.md"
echo ""
echo -e "${BLUE}🔍 To review results:${NC}"
echo "   cd $OUTPUT_DIR"
echo "   open comparison_slide_1.png  # View first comparison"
echo "   open diff_slide_1.png        # View first difference analysis"
echo ""
echo -e "${GREEN}Happy comparing! 🎉${NC}"
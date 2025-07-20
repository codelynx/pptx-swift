#!/bin/bash
# Setup script for PPTX rendering tests

set -e

echo "Setting up PPTX rendering test environment..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This script is designed for macOS"
    exit 1
fi

# Create directories
echo "Creating test directories..."
mkdir -p tests/fixtures/basic
mkdir -p tests/visual-baselines/approved
mkdir -p tests/visual-output/current
mkdir -p tests/references/libreoffice

echo "Setup complete!"
echo ""
echo "To test LibreOffice rendering:"
echo "soffice --headless --convert-to pdf samples/sample1_SSI_Chap2.pptx"
echo ""
echo "To convert PDF to PNG:"
echo "convert -density 300 sample1_SSI_Chap2.pdf slide-%d.png"
#!/usr/bin/env python3
"""
Generate reference images for PPTX slides using various methods.
This demonstrates different approaches for creating test references.
"""

import os
import sys
import subprocess
from pathlib import Path

def check_dependencies():
    """Check if required tools are installed."""
    tools = {
        'ImageMagick': ['convert', '--version'],
        'Ghostscript': ['gs', '--version']
    }
    
    available = {}
    for name, cmd in tools.items():
        try:
            subprocess.run(cmd, capture_output=True, check=True)
            available[name] = True
            print(f"✓ {name} is installed")
        except (subprocess.CalledProcessError, FileNotFoundError):
            available[name] = False
            print(f"✗ {name} is not installed")
    
    return available

def pptx_to_pdf_with_preview(pptx_path, output_path):
    """
    Use macOS Preview app to convert PPTX to PDF.
    This is a fallback when LibreOffice isn't available.
    """
    applescript = f'''
    tell application "Preview"
        open POSIX file "{pptx_path}"
        delay 2
        
        tell application "System Events"
            keystroke "p" using command down
            delay 1
            
            click button "PDF" of sheet 1 of window 1 of process "Preview"
            delay 0.5
            
            click menu item "Save as PDF" of menu 1 of button "PDF" of sheet 1 of window 1 of process "Preview"
            delay 1
            
            keystroke "{output_path}"
            delay 0.5
            
            click button "Save" of sheet 1 of window 1 of process "Preview"
            delay 2
        end tell
        
        quit
    end tell
    '''
    
    # Note: This requires accessibility permissions
    subprocess.run(['osascript', '-e', applescript])

def pdf_to_images(pdf_path, output_dir, dpi=300):
    """Convert PDF to PNG images using ImageMagick."""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    cmd = [
        'convert',
        '-density', str(dpi),
        '-quality', '100',
        pdf_path,
        str(output_dir / 'slide-%d.png')
    ]
    
    try:
        subprocess.run(cmd, check=True)
        print(f"✓ Converted PDF to images in {output_dir}")
    except subprocess.CalledProcessError as e:
        print(f"✗ Failed to convert PDF: {e}")

def generate_reference_data(pptx_path):
    """Generate JSON metadata about the PPTX for testing."""
    import json
    from datetime import datetime
    
    metadata = {
        'source': str(pptx_path),
        'generated': datetime.now().isoformat(),
        'method': 'manual',
        'dpi': 300,
        'slides': []
    }
    
    # In a real implementation, we'd extract slide count and info
    # For now, just create a template
    
    output_path = Path(pptx_path).with_suffix('.json')
    with open(output_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"✓ Generated metadata: {output_path}")

def main():
    print("PPTX Test Reference Generator")
    print("=" * 40)
    
    # Check dependencies
    deps = check_dependencies()
    
    if len(sys.argv) < 2:
        print("\nUsage: python3 generate_test_references.py <pptx_file>")
        print("\nThis script demonstrates how to generate reference images")
        print("when LibreOffice is not available.")
        return
    
    pptx_path = Path(sys.argv[1])
    if not pptx_path.exists():
        print(f"Error: File not found: {pptx_path}")
        return
    
    output_dir = Path("tests/references") / pptx_path.stem
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"\nProcessing: {pptx_path}")
    print(f"Output directory: {output_dir}")
    
    # Generate metadata
    generate_reference_data(pptx_path)
    
    # If we had LibreOffice, we'd use it here
    # For demo purposes, show what the command would be
    print("\nLibreOffice command (if available):")
    print(f"soffice --headless --convert-to pdf --outdir {output_dir} {pptx_path}")
    
    if deps['ImageMagick']:
        print("\nTo convert existing PDFs to images:")
        print(f"convert -density 300 <pdf_file> {output_dir}/slide-%d.png")
    
    print("\n✓ Reference generation setup complete")

if __name__ == "__main__":
    main()
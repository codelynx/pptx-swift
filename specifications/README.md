# PPTX Specifications - ECMA-376 Office Open XML

This directory contains the complete ECMA-376 Office Open XML specifications and related resources.

## Directory Structure

```
pptx-specifications/
├── pdfs/              # ECMA-376 specification documents
├── schemas/           # XML validation schemas
│   ├── xsd/          # XML Schema Definition files
│   ├── relaxng/      # RELAX NG schema files
│   └── packaging/    # Open Packaging Convention schemas
├── resources/         # Preset definitions and assets
│   ├── drawingml/    # Shape and text effect definitions
│   ├── spreadsheetml/# Excel style presets
│   └── wordprocessingml/# Border art images
├── archives/          # Original ZIP files (preserved)
├── DOCUMENTATION_ANALYSIS_REPORT.md
└── PACKAGE_MANIFEST.md
```

## Key Documents

### PDF Specifications
1. **Part 1** - Fundamentals and Markup Language Reference (34 MB)
   - Complete PresentationML specification for PowerPoint
   - DrawingML for graphics and charts
   - SpreadsheetML and WordprocessingML references

2. **Part 2** - Open Packaging Conventions (1.9 MB)
   - ZIP package structure
   - Relationships model
   - Content types

3. **Part 3** - Markup Compatibility and Extensibility (844 KB)
   - Extension mechanisms
   - Version compatibility

4. **Part 4** - Transitional Migration Features (9.7 MB)
   - Legacy format support
   - VML compatibility

### Schema Organization

#### XSD Schemas
- **strict/** - Modern OOXML schemas (21 files)
- **transitional/** - Includes VML for compatibility (26 files)

#### RELAX NG Schemas
- **strict/** - RELAX NG format (86 files)
- **transitional/** - With VML support (92 files)

#### Packaging Schemas
- Core package structure schemas
- Both XSD and RELAX NG formats

### Resources

#### DrawingML (2 files)
- `presetShapeDefinitions.xml` - 187 preset shapes
- `presetTextWarpDefinitions.xml` - Text effects

#### SpreadsheetML (3 files)
- Excel cell and table style presets
- Sample pivot table formats

#### WordprocessingML (1,320 files)
- Decorative border art as PNG images
- 165 unique styles × 8 positions each

## For PPTX Development

Most relevant files for PowerPoint parsing:
1. Start with Part 2 PDF (package structure)
2. Reference Part 1 PDF, PresentationML section
3. Use `schemas/xsd/strict/pml.xsd` for validation
4. Check DrawingML schemas for graphics

## Total Size
- PDFs: 46.8 MB
- Schemas: ~400 KB
- Resources: 14.2 MB
- Total: ~114 MB (including extracted files)
# Package Manifest

This document lists all archive files in the `archives/` directory and their extraction details.

## Schema Archives

### OfficeOpenXML-XMLSchema-Strict.zip
- **Extracted to:** `schemas/xsd/strict/`
- **Description:** XML Schema Definition (XSD) files for Office Open XML Strict conformance
- **Files extracted:** 21
- **Contents:** Core schema definitions including DrawingML (dml-*.xsd), PresentationML (pml.xsd), SpreadsheetML (sml.xsd), and WordprocessingML (wml.xsd)

### OfficeOpenXML-XMLSchema-Transitional.zip
- **Extracted to:** `schemas/xsd/transitional/`
- **Description:** XML Schema Definition (XSD) files for Office Open XML Transitional conformance
- **Files extracted:** 26
- **Contents:** Extended schema definitions for backward compatibility, including all core schemas plus transitional features

### OfficeOpenXML-RELAXNG-Strict.zip
- **Extracted to:** `schemas/relaxng/strict/`
- **Description:** RELAX NG schema files for Office Open XML Strict conformance
- **Files extracted:** 86
- **Contents:** Alternative schema format using RELAX NG notation for stricter validation

### OfficeOpenXML-RELAXNG-Transitional.zip
- **Extracted to:** `schemas/relaxng/transitional/`
- **Description:** RELAX NG schema files for Office Open XML Transitional conformance
- **Files extracted:** 92
- **Contents:** RELAX NG schemas including transitional features for backward compatibility

### OpenPackagingConventions-XMLSchema.zip
- **Extracted to:** `schemas/packaging/xsd/`
- **Description:** XML Schema definitions for Open Packaging Conventions (OPC)
- **Files extracted:** 4
- **Contents:** Core packaging schemas for content types, relationships, and digital signatures

### OpenPackagingConventions-RELAXNG.zip
- **Extracted to:** `schemas/packaging/relaxng/`
- **Description:** RELAX NG schemas for Open Packaging Conventions
- **Files extracted:** 5
- **Contents:** Alternative RELAX NG format for OPC validation

## Resource Archives

### OfficeOpenXML-DrawingMLGeometries.zip
- **Extracted to:** `resources/drawingml/`
- **Description:** DrawingML preset shape and text warp definitions
- **Files extracted:** 2
- **Contents:** 
  - `presetShapeDefinitions.xml` - Defines preset shapes (rectangles, circles, arrows, etc.)
  - `presetTextWarpDefinitions.xml` - Defines text warping effects

### OfficeOpenXML-SpreadsheetMLStyles.zip
- **Extracted to:** `resources/spreadsheetml/`
- **Description:** SpreadsheetML style definitions and presets
- **Files extracted:** 3
- **Contents:** Predefined styles, formats, and themes for spreadsheet applications

### OfficeOpenXML-WordprocessingMLArtBorders.zip
- **Extracted to:** `resources/wordprocessingml/`
- **Description:** WordprocessingML artistic border image resources
- **Files extracted:** 1,320
- **Contents:** PNG images for decorative borders (apples, balloons, birds, etc.) in various positions

## Summary

Total archives extracted: 9
Total files extracted: 1,559

All archives have been successfully extracted to their designated directories within the pptx-specifications folder structure.
# PPTX Swift Architecture

## Overview

PPTX Swift is designed as a modular Swift package with clear separation between the core parsing library (PPTXKit) and the command-line interface (PPTXAnalyzerCLI).

```
┌─────────────────────┐
│  PPTXAnalyzerCLI    │  Command-line interface
│  ┌───────────────┐  │
│  │   Commands    │  │
│  └───────────────┘  │
└──────────┬──────────┘
           │ uses
┌──────────▼──────────┐
│      PPTXKit        │  Core parsing library
│  ┌───────────────┐  │
│  │    Models     │  │
│  ├───────────────┤  │
│  │   Parsers     │  │
│  └───────────────┘  │
└─────────────────────┘
           │ uses
┌──────────▼──────────┐
│   ZIPFoundation     │  External dependency
└─────────────────────┘
```

## Component Architecture

### PPTXKit (Core Library)

The core library handles all PPTX parsing logic and provides a clean API for clients.

#### Key Components:

1. **PPTXDocument**
   - Main entry point for PPTX parsing
   - Manages ZIP archive access
   - Coordinates parsing operations
   - Provides high-level API methods

2. **XML Parsers**
   - `XMLParser`: Generic XML parsing for presentations and slides
   - `MetadataXMLParser`: Specialized parser for document properties
   - `SlideRelationshipsParser`: Parses slide relationships

3. **Data Models**
   - `Slide`: Represents individual slide data
   - `PresentationMetadata`: Contains presentation-level metadata
   - `Relationship`: Models relationships between resources

### PPTXAnalyzerCLI

The CLI layer provides user-facing commands using Swift Argument Parser.

#### Command Structure:

```
pptx-analyzer (main)
├── count    - Get slide count
├── list     - List all slides
├── info     - Get slide details
└── summary  - Show presentation metadata
```

Each command:
- Handles argument parsing
- Validates inputs
- Calls PPTXKit APIs
- Formats output
- Manages error reporting

## Data Flow

### Reading a PPTX File

```
1. User invokes CLI command
   ↓
2. Command validates arguments
   ↓
3. PPTXDocument opens ZIP archive
   ↓
4. Validates PPTX structure
   ↓
5. Parses requested XML files
   ↓
6. Returns structured data
   ↓
7. Command formats output
   ↓
8. Display to user
```

### XML Parsing Strategy

PPTX files are ZIP archives containing XML files. The parsing strategy:

1. **Lazy Loading**: XML files are only parsed when needed
2. **SAX Parsing**: Uses NSXMLParser for memory efficiency
3. **Targeted Extraction**: Only extracts required information

### Key XML Files:

- `[Content_Types].xml`: Content type definitions
- `_rels/.rels`: Root relationships
- `ppt/presentation.xml`: Presentation structure and slide list
- `ppt/_rels/presentation.xml.rels`: Presentation relationships
- `ppt/slides/slide*.xml`: Individual slide content
- `ppt/slides/_rels/slide*.xml.rels`: Slide relationships
- `docProps/core.xml`: Core document properties
- `docProps/app.xml`: Application properties

## Error Handling

The architecture uses Swift's error handling with custom error types:

```swift
PPTXError
├── fileNotFound
├── invalidPPTXFile
├── corruptedArchive
├── missingRequiredFile(String)
└── invalidXML(String)
```

Errors propagate from PPTXKit to CLI, where they're mapped to appropriate exit codes.

## Design Decisions

### 1. Separation of Concerns
- Core parsing logic isolated in PPTXKit
- CLI concerns handled separately
- Clean API boundaries

### 2. Read-Only Design
- Focuses on analysis and extraction
- No modification capabilities
- Simplifies implementation

### 3. On-Demand Parsing
- Slides parsed individually when requested
- Reduces memory usage for large files
- Improves performance for targeted operations

### 4. XML Parser Choice
- Uses Foundation's XMLParser (SAX-based)
- Memory efficient for large files
- Suitable for targeted data extraction

### 5. Structured Data Models
- Strong typing with Swift structs
- Immutable data models
- Clear API contracts

## Extension Points

The architecture supports future extensions:

1. **Additional Commands**: New CLI commands can be added easily
2. **Output Formats**: New formatters can be implemented
3. **Enhanced Parsing**: Additional XML elements can be parsed
4. **Write Support**: Could be added to PPTXKit
5. **Streaming API**: For processing very large files

## Performance Considerations

1. **Memory Usage**
   - ZIP entries extracted to memory
   - XML parsed incrementally
   - Suitable for typical presentations

2. **Parsing Speed**
   - On-demand parsing avoids unnecessary work
   - SAX parsing is efficient
   - File I/O is the main bottleneck

3. **Scalability**
   - Works well for presentations up to hundreds of slides
   - Very large files may require streaming approach

## Testing Strategy

1. **Unit Tests**
   - Test individual parsers
   - Test data models
   - Mock ZIP archive for isolation

2. **Integration Tests**
   - Test with real PPTX files
   - Verify end-to-end functionality

3. **CLI Tests**
   - Test command parsing
   - Verify output formatting
   - Check error handling

## Security Considerations

1. **Input Validation**
   - Validates ZIP structure
   - Checks for required files
   - Handles malformed XML gracefully

2. **Resource Limits**
   - No unbounded memory allocation
   - Reasonable limits on string sizes

3. **File System Access**
   - Read-only operations
   - No path traversal vulnerabilities
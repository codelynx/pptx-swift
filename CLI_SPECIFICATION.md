# PPTX Analyzer CLI Specification

## Overview
Command-line utility for parsing and analyzing PowerPoint (PPTX) files.

## Command Name
`pptx-analyzer` or `pptxa`

## Basic Usage
```bash
pptx-analyzer <command> [options] <file.pptx>
```

## Commands

### 1. Count - Get slide count
```bash
pptx-analyzer count <file.pptx>
```
Output: Single number representing total slide count

### 2. List - List all slides
```bash
pptx-analyzer list [options] <file.pptx>
```

Options:
- `--format <format>`: Output format (default: simple)
  - `simple`: One slide per line with index and ID
  - `json`: JSON array with slide metadata
  - `table`: Formatted table
- `--verbose, -v`: Include additional metadata (title, layout type)

Example output (simple):
```
1: slide1
2: slide2
3: slide3
```

Example output (verbose):
```
1: slide1 [Title Slide] "Welcome to My Presentation"
2: slide2 [Title and Content] "Introduction"
3: slide3 [Two Content] "Comparison"
```

### 3. Info - Get detailed information about specific slide
```bash
pptx-analyzer info [options] <file.pptx>
```

Options (mutually exclusive):
- `--index <n>, -n <n>`: Slide by 1-based index
- `--id <slide-id>`: Slide by ID (e.g., "slide1")

Output includes:
- Slide ID
- Slide index (position)
- Layout type
- Title (if present)
- Number of shapes
- Text content summary
- Notes (if present)
- Relationships (images, charts, etc.)

Example:
```bash
pptx-analyzer info --index 2 presentation.pptx
pptx-analyzer info --id slide2 presentation.pptx
```

### 4. Summary - Overall presentation summary
```bash
pptx-analyzer summary <file.pptx>
```

Output includes:
- Total slides
- Presentation title
- Author metadata
- Creation/modification dates
- Slide masters count
- Layouts used
- Media assets count

## Global Options

- `--help, -h`: Show help message
- `--version`: Show version information
- `--quiet, -q`: Minimal output (errors only)
- `--output <file>, -o <file>`: Write output to file instead of stdout

## Error Handling

Exit codes:
- 0: Success
- 1: File not found
- 2: Invalid PPTX file
- 3: Invalid command or arguments
- 4: Slide not found (for info command)

## Usage Examples

```bash
# Get slide count
pptx-analyzer count presentation.pptx
# Output: 25

# List all slides with details
pptx-analyzer list --verbose presentation.pptx

# Get info about 5th slide
pptx-analyzer info --index 5 presentation.pptx

# Get info about specific slide by ID
pptx-analyzer info --id slide10 presentation.pptx

# Save slide list as JSON
pptx-analyzer list --format json -o slides.json presentation.pptx

# Get presentation summary
pptx-analyzer summary presentation.pptx
```

## Future Command Ideas (not in initial implementation)

- `extract`: Extract slide as individual PPTX
- `text`: Extract all text content
- `media`: List/extract media assets
- `validate`: Validate against ECMA-376 schema
- `compare`: Compare two presentations

## Implementation Notes

1. Commands should be modular and easy to extend
2. Support both positional and named arguments
3. Provide helpful error messages
4. Support piping and redirection
5. Consider using Swift Argument Parser for implementation
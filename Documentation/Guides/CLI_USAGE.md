# PPTX Analyzer CLI Usage Guide

## Installation

### Building from Source

```bash
git clone https://github.com/yourusername/pptx-swift.git
cd pptx-swift
swift build -c release
```

The executable will be located at `.build/release/pptx-analyzer`.

### Installing System-wide

```bash
sudo cp .build/release/pptx-analyzer /usr/local/bin/
```

## Commands

### count

Get the total number of slides in a PPTX file.

```bash
pptx-analyzer count <file.pptx>
```

**Options:**
- `-q, --quiet`: Minimal output (errors only)
- `-o, --output <file>`: Write output to file instead of stdout

**Example:**
```bash
$ pptx-analyzer count presentation.pptx
11

$ pptx-analyzer count -o count.txt presentation.pptx
Slide count written to: count.txt
```

### list

List all slides in a PPTX file.

```bash
pptx-analyzer list [options] <file.pptx>
```

**Options:**
- `--format <format>`: Output format (simple, json, table)
- `-v, --verbose`: Include additional metadata
- `-q, --quiet`: Minimal output (errors only)
- `-o, --output <file>`: Write output to file instead of stdout

**Examples:**

Simple format (default):
```bash
$ pptx-analyzer list presentation.pptx
1: slide1
2: slide2
3: slide3
```

Verbose output:
```bash
$ pptx-analyzer list --verbose presentation.pptx
1: slide1 [Title Slide] "Welcome to My Presentation"
2: slide2 [Title and Content] "Introduction"
3: slide3 [Two Content] "Comparison"
```

JSON format:
```bash
$ pptx-analyzer list --format json presentation.pptx
[
  {
    "id" : "slide1",
    "index" : 1,
    "layoutType" : "",
    "title" : "Welcome"
  },
  ...
]
```

Table format:
```bash
$ pptx-analyzer list --format table presentation.pptx
Index | ID
------|----------
1     | slide1
2     | slide2
3     | slide3
```

### info

Get detailed information about a specific slide.

```bash
pptx-analyzer info [options] <file.pptx>
```

**Options (one required):**
- `-n, --index <n>`: Slide by 1-based index
- `--id <slide-id>`: Slide by ID (e.g., "slide1")
- `-q, --quiet`: Minimal output (errors only)
- `-o, --output <file>`: Write output to file instead of stdout

**Examples:**

By index:
```bash
$ pptx-analyzer info --index 1 presentation.pptx
Slide Information
=================
ID: slide1
Index: 1
Title: Chapter2-3)
Number of shapes: 3

Text Content:
-------------
1. Chapter2-3)
2. Diet & Nutrition
3. S23451

Relationships:
--------------
Images: 1
Other relationships: 2
```

By ID:
```bash
$ pptx-analyzer info --id slide5 presentation.pptx
Slide Information
=================
ID: slide5
Index: 5
Title: The answer is "Correct"
Number of shapes: 7
...
```

### summary

Get overall presentation summary and metadata.

```bash
pptx-analyzer summary [options] <file.pptx>
```

**Options:**
- `-q, --quiet`: Minimal output (errors only)
- `-o, --output <file>`: Write output to file instead of stdout

**Example:**
```bash
$ pptx-analyzer summary presentation.pptx
Presentation Summary
===================
File: presentation.pptx
Title: PowerPoint プレゼンテーション
Author: Microsoft Office ユーザー

Statistics:
-----------
Total slides: 11
Media assets: 10

Metadata:
---------
Created: Feb 3, 2019 at 21:15
Modified: Aug 1, 2023 at 10:47
Application: Microsoft Macintosh PowerPoint (v16.0000)
File size: 4.9 MB
```

## Exit Codes

- `0`: Success
- `1`: File not found
- `2`: Invalid PPTX file
- `3`: Invalid command or arguments
- `4`: Slide not found (for info command)

## Common Use Cases

### Batch Processing

Count slides in multiple files:
```bash
for file in *.pptx; do
    echo -n "$file: "
    pptx-analyzer count "$file"
done
```

### Extract All Text

Get text from all slides:
```bash
for i in $(seq 1 $(pptx-analyzer count presentation.pptx)); do
    echo "=== Slide $i ==="
    pptx-analyzer info --index $i presentation.pptx | grep -A100 "Text Content:" | tail -n +2
done
```

### JSON Processing

Process slide list with jq:
```bash
pptx-analyzer list --format json presentation.pptx | jq '.[] | select(.title != "") | .title'
```

### Validation Script

Check if presentation has required number of slides:
```bash
#!/bin/bash
MIN_SLIDES=10
count=$(pptx-analyzer count "$1")
if [ $count -lt $MIN_SLIDES ]; then
    echo "Error: Presentation has only $count slides (minimum: $MIN_SLIDES)"
    exit 1
fi
```

## Tips

1. **Performance**: The tool parses PPTX files on-demand, so repeated commands on the same file will re-parse it each time.

2. **Large Files**: For very large PPTX files, consider using the `-o` option to save output to a file for later processing.

3. **Scripting**: All commands support quiet mode (`-q`) which suppresses informational output, making them suitable for scripting.

4. **File Paths**: The tool accepts both relative and absolute file paths.

5. **Error Handling**: Use exit codes in scripts to handle different error conditions appropriately.
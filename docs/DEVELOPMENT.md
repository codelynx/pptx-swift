# Development Guide

## Prerequisites

- Swift 5.9 or later
- macOS 12.0 or later
- Xcode 15.0 or later (optional, for IDE support)

## Setting Up Development Environment

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/pptx-swift.git
cd pptx-swift
```

### 2. Build the Project

```bash
swift build
```

### 3. Run Tests

```bash
swift test
```

### 4. Generate Xcode Project (Optional)

```bash
swift package generate-xcodeproj
open PPTXAnalyzer.xcodeproj
```

## Project Structure

```
pptx-swift/
├── Package.swift              # Swift package manifest
├── Sources/
│   ├── PPTXKit/              # Core library
│   │   ├── PPTXDocument.swift
│   │   ├── XMLParser.swift
│   │   ├── MetadataXMLParser.swift
│   │   ├── SlideRelationshipsParser.swift
│   │   └── Models/
│   │       ├── Slide.swift
│   │       └── PresentationMetadata.swift
│   └── PPTXAnalyzerCLI/      # CLI application
│       ├── PPTXAnalyzer.swift
│       └── Commands/
│           ├── Count.swift
│           ├── List.swift
│           ├── Info.swift
│           └── Summary.swift
├── Tests/
│   ├── PPTXKitTests/
│   └── PPTXAnalyzerCLITests/
├── docs/                      # Documentation
├── samples/                   # Sample PPTX files (git-ignored)
└── specifications/            # ECMA-376 specifications
```

## Development Workflow

### Adding a New CLI Command

1. Create a new command file in `Sources/PPTXAnalyzerCLI/Commands/`:

```swift
import ArgumentParser
import Foundation
import PPTXKit

struct MyCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Description of my command"
    )
    
    @Argument(help: "Path to the PPTX file")
    var file: String
    
    mutating func run() throws {
        // Implementation
    }
}
```

2. Add the command to `PPTXAnalyzer.swift`:

```swift
subcommands: [
    Count.self,
    List.self,
    Info.self,
    Summary.self,
    MyCommand.self  // Add here
]
```

### Adding PPTX Parsing Features

1. Extend the XML parser in `XMLParser.swift` or create a new parser
2. Update data models if needed
3. Add methods to `PPTXDocument`
4. Write tests

### Code Style Guidelines

1. **Swift Style**
   - Follow Swift API Design Guidelines
   - Use 4-space indentation
   - Prefer `let` over `var`
   - Use meaningful variable names

2. **Error Handling**
   - Use throwing functions for operations that can fail
   - Provide descriptive error messages
   - Map errors to appropriate exit codes in CLI

3. **Documentation**
   - Document all public APIs
   - Use Swift documentation comments
   - Include usage examples

### Testing

#### Unit Tests

Create test files in `Tests/PPTXKitTests/`:

```swift
import XCTest
@testable import PPTXKit

final class MyFeatureTests: XCTestCase {
    func testFeature() throws {
        // Test implementation
    }
}
```

#### Integration Tests

Test with real PPTX files:

```swift
func testRealFile() throws {
    let url = Bundle.module.url(forResource: "test", withExtension: "pptx")!
    let document = try PPTXDocument(filePath: url.path)
    // Assertions
}
```

### Debugging

#### Debug Output

Add debug print statements during development:

```swift
#if DEBUG
print("Debug: Processing slide \(slideId)")
#endif
```

#### LLDB Debugging

```bash
# Build with debug symbols
swift build

# Run with LLDB
lldb .build/debug/pptx-analyzer
(lldb) run count sample.pptx
```

#### Examining PPTX Structure

Use `unzip` to explore PPTX files:

```bash
# List contents
unzip -l sample.pptx

# Extract specific file
unzip -p sample.pptx ppt/presentation.xml | xmllint --format -

# Extract all files
unzip sample.pptx -d extracted/
```

## Common Tasks

### Updating Dependencies

Edit `Package.swift` and run:

```bash
swift package update
```

### Building for Release

```bash
swift build -c release
```

### Creating a Distribution

```bash
swift build -c release
cp .build/release/pptx-analyzer ./
tar -czf pptx-analyzer-macos.tar.gz pptx-analyzer
```

### Running Benchmarks

```bash
# Time a command
time .build/release/pptx-analyzer count large-presentation.pptx

# Profile with Instruments
instruments -t "Time Profiler" .build/release/pptx-analyzer list large.pptx
```

## Troubleshooting

### Build Errors

1. **Missing dependencies**: Run `swift package resolve`
2. **Clean build**: `swift package clean && swift build`
3. **Xcode issues**: Delete `.build` and regenerate project

### Runtime Issues

1. **File not found**: Check file paths are correct
2. **Invalid PPTX**: Verify with `unzip -t file.pptx`
3. **Memory issues**: Check for large media files in PPTX

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Update documentation
6. Submit a pull request

### Pull Request Checklist

- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] New features have tests
- [ ] Documentation is updated
- [ ] Commit messages are clear

## Resources

- [Swift Package Manager Documentation](https://swift.org/package-manager/)
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
- [ECMA-376 Specification](http://www.ecma-international.org/publications/standards/Ecma-376.htm)
- [Open XML SDK Documentation](https://docs.microsoft.com/en-us/office/open-xml/open-xml-sdk)
#!/usr/bin/env swift

import Foundation

// Function to check if a file uses spaces for indentation
func usesSpaces(file: String) -> Bool {
	guard let content = try? String(contentsOfFile: file) else { return false }
	let lines = content.components(separatedBy: .newlines)
	
	for line in lines {
		// Check if line starts with 4 spaces (common indentation)
		if line.hasPrefix("    ") {
			return true
		}
	}
	return false
}

// Function to convert spaces to tabs
func convertToTabs(file: String) {
	guard let content = try? String(contentsOfFile: file) else { return }
	
	let lines = content.components(separatedBy: .newlines)
	var convertedLines: [String] = []
	
	for line in lines {
		var convertedLine = line
		// Replace groups of 4 spaces with tabs at the beginning of lines
		while convertedLine.hasPrefix("    ") {
			convertedLine = convertedLine.replacingOccurrences(of: "    ", with: "\t", options: .anchored, range: convertedLine.startIndex..<convertedLine.endIndex)
		}
		convertedLines.append(convertedLine)
	}
	
	let convertedContent = convertedLines.joined(separator: "\n")
	try? convertedContent.write(toFile: file, atomically: true, encoding: .utf8)
}

// Find all Swift files
let fileManager = FileManager.default
let currentPath = "/Users/kyoshikawa/prj/pptx-swift"

func findSwiftFiles(in directory: String) -> [String] {
	var swiftFiles: [String] = []
	
	if let enumerator = fileManager.enumerator(atPath: directory) {
		for case let file as String in enumerator {
			if file.hasSuffix(".swift") && 
			   !file.contains(".build") && 
			   !file.contains("DerivedData") &&
			   !file.contains("xcuserdata") {
				let fullPath = (directory as NSString).appendingPathComponent(file)
				swiftFiles.append(fullPath)
			}
		}
	}
	
	return swiftFiles
}

// Main execution
let swiftFiles = findSwiftFiles(in: currentPath)
var filesWithSpaces: [String] = []

print("Checking \(swiftFiles.count) Swift files...")

for file in swiftFiles {
	if usesSpaces(file: file) {
		filesWithSpaces.append(file)
		print("Found spaces in: \(file)")
	}
}

print("\nFound \(filesWithSpaces.count) files with spaces")

if !filesWithSpaces.isEmpty {
	print("\nDo you want to convert these files to tabs? (y/n)")
	if let response = readLine(), response.lowercased() == "y" {
		for file in filesWithSpaces {
			print("Converting: \(file)")
			convertToTabs(file: file)
		}
		print("\nConversion complete!")
	} else {
		print("Conversion cancelled.")
	}
}
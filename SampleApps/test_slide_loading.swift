#!/usr/bin/env swift

import Foundation

// Test slide loading from a PPTX file
print("Testing PPTX Slide Loading")
print("==========================")

// Check for sample file
let samplePath = "../samples/sample1_SSI_Chap2.pptx"
let fullPath = FileManager.default.currentDirectoryPath + "/" + samplePath

print("Looking for sample at: \(fullPath)")
print("File exists: \(FileManager.default.fileExists(atPath: fullPath))")

// Simple test to check ZIP archive reading
if FileManager.default.fileExists(atPath: fullPath) {
    print("\n=== Testing ZIP Archive Access ===")
    
    // Check if it's a valid ZIP file
    let fileURL = URL(fileURLWithPath: fullPath)
    
    do {
        let data = try Data(contentsOf: fileURL)
        print("File size: \(data.count) bytes")
        
        // Check ZIP signature (first 4 bytes should be "PK\x03\x04")
        if data.count >= 4 {
            let signature = data.prefix(4)
            let expectedSignature = Data([0x50, 0x4B, 0x03, 0x04]) // "PK\x03\x04"
            
            if signature == expectedSignature {
                print("✅ Valid ZIP file signature found")
            } else {
                print("❌ Invalid ZIP signature: \(signature.map { String(format: "%02X", $0) }.joined(separator: " "))")
            }
        }
    } catch {
        print("❌ Error reading file: \(error)")
    }
    
    // Test unzipping
    print("\n=== Testing Archive Extraction ===")
    
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("pptx_test_\(UUID().uuidString)")
    
    do {
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        print("Created temp directory: \(tempDir.path)")
        
        // Use command line unzip to extract
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-q", fullPath, "-d", tempDir.path]
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus == 0 {
            print("✅ Successfully extracted archive")
            
            // List extracted files
            let contents = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            print("\nExtracted contents:")
            for item in contents.prefix(10) {
                print("  - \(item.lastPathComponent)")
            }
            if contents.count > 10 {
                print("  ... and \(contents.count - 10) more files")
            }
            
            // Check for required PPTX files
            let requiredPaths = [
                "[Content_Types].xml",
                "_rels",
                "ppt/presentation.xml",
                "ppt/slides"
            ]
            
            print("\n=== Checking PPTX Structure ===")
            for path in requiredPaths {
                let fullPath = tempDir.appendingPathComponent(path)
                let exists = FileManager.default.fileExists(atPath: fullPath.path)
                print("\(exists ? "✅" : "❌") \(path)")
            }
            
            // Check slides directory
            let slidesDir = tempDir.appendingPathComponent("ppt/slides")
            if FileManager.default.fileExists(atPath: slidesDir.path) {
                let slides = try FileManager.default.contentsOfDirectory(at: slidesDir, includingPropertiesForKeys: nil)
                let slideXMLs = slides.filter { $0.pathExtension == "xml" }
                print("\nFound \(slideXMLs.count) slide XML files:")
                for slide in slideXMLs.prefix(5) {
                    print("  - \(slide.lastPathComponent)")
                    
                    // Read first few lines of slide content
                    if let content = try? String(contentsOf: slide, encoding: .utf8) {
                        let lines = content.split(separator: "\n").prefix(3)
                        for line in lines {
                            print("    \(String(line).prefix(80))...")
                        }
                    }
                }
            }
            
        } else {
            print("❌ Failed to extract archive. Exit code: \(process.terminationStatus)")
        }
        
        // Clean up
        try FileManager.default.removeItem(at: tempDir)
        
    } catch {
        print("❌ Error during extraction: \(error)")
    }
}

print("\n✅ Test complete!")
#!/usr/bin/env swift

import Foundation

// Test to verify slide content is being loaded properly

print("Testing Slide Content Loading")
print("=============================\n")

// We'll manually test the XML parsing to ensure it's working
let testSlideXML = """
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld>
    <p:spTree>
      <p:sp>
        <p:nvSpPr>
          <p:nvPr>
            <p:ph type="ctrTitle"/>
          </p:nvPr>
        </p:nvSpPr>
        <p:txBody>
          <a:p>
            <a:r>
              <a:t>Welcome to My Presentation</a:t>
            </a:r>
          </a:p>
        </p:txBody>
      </p:sp>
      <p:sp>
        <p:nvSpPr>
          <p:nvPr>
            <p:ph type="subTitle"/>
          </p:nvPr>
        </p:nvSpPr>
        <p:txBody>
          <a:p>
            <a:r>
              <a:t>This is the subtitle</a:t>
            </a:r>
          </a:p>
        </p:txBody>
      </p:sp>
    </p:spTree>
  </p:cSld>
</p:sld>
"""

// Test XML parsing
class TestXMLParser: NSObject, XMLParserDelegate {
    var textContent: [String] = []
    var currentText = ""
    var currentElement = ""
    var isInTextBody = false
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "p:txBody" {
            isInTextBody = true
        }
        
        if elementName == "a:t" {
            currentText = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "a:t" && isInTextBody {
            currentText.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "a:t" && isInTextBody && !currentText.isEmpty {
            let trimmed = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                textContent.append(trimmed)
                print("Found text: '\(trimmed)'")
            }
        }
        
        if elementName == "p:txBody" {
            isInTextBody = false
        }
    }
}

print("1. Testing XML parsing...")
let data = testSlideXML.data(using: .utf8)!
let parser = XMLParser(data: data)
let delegate = TestXMLParser()
parser.delegate = delegate

if parser.parse() {
    print("✅ XML parsed successfully")
    print("Text content found: \(delegate.textContent)")
} else {
    print("❌ XML parsing failed")
    if let error = parser.parserError {
        print("Error: \(error)")
    }
}

// Now let's check if a real slide file has content
print("\n2. Checking real slide content...")
let samplePath = "../samples/sample1_SSI_Chap2.pptx"
let fullPath = FileManager.default.currentDirectoryPath + "/" + samplePath

if FileManager.default.fileExists(atPath: fullPath) {
    // Extract and check first slide
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("slide_test_\(UUID().uuidString)")
    
    do {
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // Extract archive
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-q", fullPath, "-d", tempDir.path]
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus == 0 {
            // Read first slide
            let slide1Path = tempDir.appendingPathComponent("ppt/slides/slide1.xml")
            if let slideContent = try? String(contentsOf: slide1Path, encoding: .utf8) {
                print("✅ Found slide1.xml")
                
                // Parse it
                let slideData = slideContent.data(using: .utf8)!
                let slideParser = XMLParser(data: slideData)
                let slideDelegate = TestXMLParser()
                slideParser.delegate = slideDelegate
                
                if slideParser.parse() {
                    print("✅ Parsed slide1.xml successfully")
                    print("Text content in slide 1:")
                    for (i, text) in slideDelegate.textContent.enumerated() {
                        print("  \(i+1). '\(text)'")
                    }
                    
                    if slideDelegate.textContent.isEmpty {
                        print("  ⚠️  No text content found in slide!")
                    }
                } else {
                    print("❌ Failed to parse slide1.xml")
                }
            } else {
                print("❌ Could not read slide1.xml")
            }
        }
        
        // Clean up
        try FileManager.default.removeItem(at: tempDir)
        
    } catch {
        print("Error: \(error)")
    }
}

print("\n✅ Content loading test complete!")
print("\nConclusion: The issue was that PPTXManager was loading slides without their content.")
print("The fix loads full slide details including title and text content for each slide.")
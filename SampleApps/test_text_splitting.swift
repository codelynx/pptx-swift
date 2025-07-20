#!/usr/bin/env swift

import Foundation

// Test to diagnose text splitting issue with "Diet & Nutrition"

print("Testing Text Splitting Issue")
print("===========================\n")

// This XML represents a common case where text might be split across multiple runs
let testSlideXML = """
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld>
    <p:spTree>
      <p:sp>
        <p:txBody>
          <a:p>
            <!-- Text split across multiple runs due to formatting -->
            <a:r>
              <a:rPr lang="en-US" sz="2400" b="1"/>
              <a:t>D</a:t>
            </a:r>
            <a:r>
              <a:rPr lang="en-US" sz="2400"/>
              <a:t>iet &amp; Nutrition</a:t>
            </a:r>
          </a:p>
        </p:txBody>
      </p:sp>
    </p:spTree>
  </p:cSld>
</p:sld>
"""

// Enhanced XML parser that tracks runs within paragraphs
class EnhancedXMLParser: NSObject, XMLParserDelegate {
    var paragraphs: [[String]] = []
    var currentParagraphTexts: [String] = []
    var currentText = ""
    var currentElement = ""
    var isInTextBody = false
    var isInParagraph = false
    var isInRun = false
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "p:txBody" {
            isInTextBody = true
        }
        
        if elementName == "a:p" && isInTextBody {
            isInParagraph = true
            currentParagraphTexts = []
        }
        
        if elementName == "a:r" && isInParagraph {
            isInRun = true
        }
        
        if elementName == "a:t" && isInRun {
            currentText = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "a:t" && isInRun {
            currentText.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "a:t" && isInRun {
            currentParagraphTexts.append(currentText)
            print("  Found text run: '\(currentText)'")
        }
        
        if elementName == "a:r" && isInParagraph {
            isInRun = false
        }
        
        if elementName == "a:p" && isInTextBody {
            if !currentParagraphTexts.isEmpty {
                paragraphs.append(currentParagraphTexts)
                let combinedText = currentParagraphTexts.joined()
                print("  Paragraph complete: '\(combinedText)'")
            }
            isInParagraph = false
        }
        
        if elementName == "p:txBody" {
            isInTextBody = false
        }
    }
}

print("1. Testing XML with split text runs...")
let data = testSlideXML.data(using: .utf8)!
let parser = XMLParser(data: data)
let delegate = EnhancedXMLParser()
parser.delegate = delegate

if parser.parse() {
    print("\n✅ XML parsed successfully")
    print("\nAnalysis:")
    print("- Found \(delegate.paragraphs.count) paragraph(s)")
    
    for (i, paragraph) in delegate.paragraphs.enumerated() {
        print("\nParagraph \(i+1):")
        print("  - Number of text runs: \(paragraph.count)")
        print("  - Individual runs: \(paragraph)")
        print("  - Combined text: '\(paragraph.joined())'")
    }
    
    print("\n⚠️  Issue identified: Text is being split across multiple <a:r> (run) elements!")
    print("   This is why 'Diet & Nutrition' appears as 'D' and 'iet & Nutrition'")
    
} else {
    print("❌ XML parsing failed")
    if let error = parser.parserError {
        print("Error: \(error)")
    }
}

print("\n2. Current PPTXXMLParser behavior...")
print("The current XMLParser.swift implementation:")
print("- Collects text from each <a:t> element separately")
print("- Adds each text to the textContent array individually")
print("- Does NOT combine text runs within the same paragraph")

print("\n3. Solution:")
print("To fix this issue, the XMLParser needs to:")
print("1. Track when we're inside a paragraph (<a:p>)")
print("2. Collect all text runs (<a:r>) within that paragraph")
print("3. Combine them into a single text string per paragraph")
print("4. Only add the combined paragraph text to the textContent array")

print("\n✅ Diagnosis complete!")
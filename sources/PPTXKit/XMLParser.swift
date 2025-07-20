import Foundation

/// Helper class for parsing XML content from PPTX files
class PPTXXMLParser: NSObject {
	private var currentElement = ""
	private var foundElements: [String: String] = [:]
	private var slideInfoList: [(id: String, rId: String)] = []
	private var relationships: [String: String] = [:]  // rId -> target path
	private var slideLayouts: [String: String] = [:]  // rId -> layout name
	
	// For slide parsing
	private var textContent: [String] = []
	private var shapeCount: Int = 0
	private var currentText: String = ""
	private var isInTextBody: Bool = false
	private var slideTitle: String? = nil
	private var placeholderType: String? = nil
	private var currentParagraphText: String = ""
	private var isInParagraph: Bool = false
	
	/// Parse presentation.xml to get slide information
	func parsePresentation(data: Data) throws -> [(id: String, rId: String)] {
		slideInfoList.removeAll()
		
		let parser = XMLParser(data: data)
		parser.delegate = self
		
		guard parser.parse() else {
			if let error = parser.parserError {
				throw PPTXDocument.PPTXError.invalidXML("presentation.xml: \(error.localizedDescription)")
			} else {
				throw PPTXDocument.PPTXError.invalidXML("presentation.xml")
			}
		}
		
		return slideInfoList
	}
	
	/// Extract slide count from presentation.xml
	func extractSlideCount(from data: Data) throws -> Int {
		let slides = try parsePresentation(data: data)
		return slides.count
	}
	
	/// Parse relationships XML to map rIds to file paths
	func parseRelationships(data: Data) throws -> [String: String] {
		relationships.removeAll()
		
		let parser = XMLParser(data: data)
		parser.delegate = self
		
		guard parser.parse() else {
			if let error = parser.parserError {
				throw PPTXDocument.PPTXError.invalidXML("relationships: \(error.localizedDescription)")
			} else {
				throw PPTXDocument.PPTXError.invalidXML("relationships")
			}
		}
		
		return relationships
	}
	
	/// Parse a slide XML to extract content
	func parseSlide(data: Data) throws -> (title: String?, textContent: [String], shapeCount: Int) {
		// Reset state
		textContent.removeAll()
		shapeCount = 0
		currentText = ""
		isInTextBody = false
		slideTitle = nil
		placeholderType = nil
		currentParagraphText = ""
		isInParagraph = false
		
		let parser = XMLParser(data: data)
		parser.delegate = self
		
		guard parser.parse() else {
			if let error = parser.parserError {
				throw PPTXDocument.PPTXError.invalidXML("slide: \(error.localizedDescription)")
			} else {
				throw PPTXDocument.PPTXError.invalidXML("slide")
			}
		}
		
		// Clean up text content
		let cleanedText = textContent.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
		
		return (title: slideTitle, textContent: cleanedText, shapeCount: shapeCount)
	}
}

// MARK: - XMLParserDelegate
extension PPTXXMLParser: XMLParserDelegate {
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		currentElement = elementName
		
		// Look for slide ID elements
		if elementName == "p:sldId" {
			if let id = attributeDict["id"], let rId = attributeDict["r:id"] {
				slideInfoList.append((id: id, rId: rId))
			}
		}
		
		// Look for relationship elements
		if elementName == "Relationship" {
			if let id = attributeDict["Id"], 
			   let target = attributeDict["Target"],
			   let type = attributeDict["Type"],
			   type.contains("slide") && !type.contains("slideMaster") && !type.contains("slideLayout") {
				relationships[id] = target
			}
		}
		
		// For slide parsing
		if elementName == "p:sp" || elementName == "p:pic" || elementName == "p:graphicFrame" {
			shapeCount += 1
		}
		
		if elementName == "p:ph" {
			placeholderType = attributeDict["type"]
		}
		
		if elementName == "p:txBody" {
			isInTextBody = true
		}
		
		// Track paragraph starts
		if elementName == "a:p" && isInTextBody {
			isInParagraph = true
			currentParagraphText = ""
		}
		
		if elementName == "a:t" {
			currentText = ""
			currentElement = elementName
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		if currentElement == "a:t" && isInTextBody {
			currentText.append(string)
		}
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "a:t" && isInTextBody && isInParagraph && !currentText.isEmpty {
			// Append text run to current paragraph
			currentParagraphText.append(currentText)
		}
		
		// When paragraph ends, add the complete paragraph text
		if elementName == "a:p" && isInParagraph {
			isInParagraph = false
			let trimmed = currentParagraphText.trimmingCharacters(in: .whitespacesAndNewlines)
			if !trimmed.isEmpty {
				textContent.append(trimmed)
				
				// Check if this is a title based on placeholder type
				if placeholderType == "ctrTitle" || placeholderType == "title" {
					if slideTitle == nil {
						slideTitle = trimmed
					}
				}
			}
			currentParagraphText = ""
		}
		
		if elementName == "p:txBody" {
			isInTextBody = false
			placeholderType = nil
		}
	}
}
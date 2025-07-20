import Foundation
import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Parser for extracting detailed slide content including layout information
public class SlideXMLParser: NSObject {
	// Shape information
	public struct ShapeInfo {
		public let id: String
		public let frame: CGRect
		public let transform: CGAffineTransform
		public let type: ShapeType
		
		public enum ShapeType {
			case textBox(TextBoxInfo)
			case picture(PictureInfo)
			case shape(ShapeData)
		}
	}
	
	public struct TextBoxInfo {
		public let paragraphs: [ParagraphInfo]
		public let bodyProperties: BodyProperties
	}
	
	public struct ParagraphInfo {
		let runs: [TextRun]
		let properties: ParagraphProperties
	}
	
	public struct TextRun {
		let text: String
		let properties: RunProperties
	}
	
	public struct RunProperties {
		let fontSize: CGFloat?
		let bold: Bool
		let italic: Bool
		let underline: Bool
		let fontFamily: String?
		let color: String?
	}
	
	public struct ParagraphProperties {
		let alignment: NSTextAlignment
		let indent: CGFloat
		let bulletType: BulletType?
		let spacing: LineSpacing
	}
	
	public enum BulletType {
		case bullet(String)
		case number(String)
		case none
	}
	
	public struct LineSpacing {
		let before: CGFloat
		let after: CGFloat
		let line: CGFloat
	}
	
	public struct BodyProperties {
		let margins: EdgeInsets
		let wrap: Bool
		let anchor: TextAnchor
	}
	
	public struct EdgeInsets {
		let top: CGFloat
		let left: CGFloat
		let bottom: CGFloat
		let right: CGFloat
	}
	
	public enum TextAnchor {
		case top
		case middle
		case bottom
	}
	
	public struct PictureInfo {
		let imageRelId: String
		let frame: CGRect
	}
	
	public struct ShapeData {
		let type: String
		let fillColor: String?
		let strokeColor: String?
		let strokeWidth: CGFloat?
	}
	
	// Parser state
	private var shapes: [ShapeInfo] = []
	private var currentElement = ""
	private var currentShapeId = ""
	private var currentTransform: CGAffineTransform = .identity
	private var currentFrame: CGRect = .zero
	private var currentTextBox: TextBoxInfo?
	private var currentParagraphs: [ParagraphInfo] = []
	private var currentRuns: [TextRun] = []
	private var currentText = ""
	private var currentRunProperties: RunProperties?
	private var currentParagraphProperties: ParagraphProperties?
	private var isInShape = false
	private var isInTextBody = false
	private var isInParagraph = false
	private var isInRun = false
	
	// EMU to points conversion (1 point = 12700 EMUs)
	private let emuPerPoint: CGFloat = 12700
	
	/// Parse slide XML to extract detailed shape and text information
	public func parseSlide(data: Data) throws -> [ShapeInfo] {
		shapes.removeAll()
		resetState()
		
		let parser = XMLParser(data: data)
		parser.delegate = self
		
		guard parser.parse() else {
			if let error = parser.parserError {
				throw PPTXDocument.PPTXError.invalidXML("slide: \(error.localizedDescription)")
			} else {
				throw PPTXDocument.PPTXError.invalidXML("slide")
			}
		}
		
		return shapes
	}
	
	private func resetState() {
		currentElement = ""
		currentShapeId = ""
		currentTransform = .identity
		currentFrame = .zero
		currentTextBox = nil
		currentParagraphs = []
		currentRuns = []
		currentText = ""
		currentRunProperties = nil
		currentParagraphProperties = nil
		isInShape = false
		isInTextBody = false
		isInParagraph = false
		isInRun = false
	}
	
	private func emuToPoints(_ emu: Int) -> CGFloat {
		return CGFloat(emu) / emuPerPoint
	}
	
	private func parseTransform(from attributes: [String: String]) -> CGAffineTransform {
		// Parse rotation if present
		if let rot = attributes["rot"] {
			let angle = (Double(rot) ?? 0) / 60000.0 * .pi / 180.0
			return CGAffineTransform(rotationAngle: angle)
		}
		return .identity
	}
	
	private func parseAlignment(_ align: String?) -> NSTextAlignment {
		switch align {
		case "l", "left": return .left
		case "r", "right": return .right
		case "ctr", "center": return .center
		case "just", "justify": return .justified
		default: return .left
		}
	}
}

// MARK: - XMLParserDelegate
extension SlideXMLParser: XMLParserDelegate {
	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		currentElement = elementName
		
		// Shape container elements
		if elementName == "p:sp" || elementName == "p:pic" || elementName == "p:graphicFrame" {
			isInShape = true
			currentShapeId = "shape\(shapes.count + 1)"
			currentFrame = .zero
			currentTransform = .identity
		}
		
		// Non-visual properties (contains shape ID)
		if elementName == "p:cNvPr" && isInShape {
			if let id = attributeDict["id"] {
				currentShapeId = "shape\(id)"
			}
		}
		
		// Transform
		if elementName == "a:xfrm" && isInShape {
			currentTransform = parseTransform(from: attributeDict)
		}
		
		// Position
		if elementName == "a:off" && isInShape {
			if let x = attributeDict["x"], let y = attributeDict["y"] {
				let xPoints = emuToPoints(Int(x) ?? 0)
				let yPoints = emuToPoints(Int(y) ?? 0)
				currentFrame.origin = CGPoint(x: xPoints, y: yPoints)
			}
		}
		
		// Size
		if elementName == "a:ext" && isInShape {
			if let cx = attributeDict["cx"], let cy = attributeDict["cy"] {
				let width = emuToPoints(Int(cx) ?? 0)
				let height = emuToPoints(Int(cy) ?? 0)
				currentFrame.size = CGSize(width: width, height: height)
			}
		}
		
		// Text body
		if elementName == "p:txBody" && isInShape {
			isInTextBody = true
			currentParagraphs = []
		}
		
		// Body properties
		if elementName == "a:bodyPr" && isInTextBody {
			// Parse margins, wrap, anchor, etc.
			let margins = EdgeInsets(
				top: emuToPoints(Int(attributeDict["tIns"] ?? "") ?? 45720),
				left: emuToPoints(Int(attributeDict["lIns"] ?? "") ?? 91440),
				bottom: emuToPoints(Int(attributeDict["bIns"] ?? "") ?? 45720),
				right: emuToPoints(Int(attributeDict["rIns"] ?? "") ?? 91440)
			)
			
			let wrap = attributeDict["wrap"] != "none"
			var anchor = TextAnchor.top
			if let anchorValue = attributeDict["anchor"] {
				switch anchorValue {
				case "t": anchor = .top
				case "ctr": anchor = .middle
				case "b": anchor = .bottom
				default: anchor = .top
				}
			}
			
			// Update the current text box with body properties
			if currentTextBox != nil {
				currentTextBox = TextBoxInfo(
					paragraphs: currentTextBox!.paragraphs,
					bodyProperties: BodyProperties(
						margins: margins,
						wrap: wrap,
						anchor: anchor
					)
				)
			}
		}
		
		// Paragraph
		if elementName == "a:p" && isInTextBody {
			isInParagraph = true
			currentRuns = []
			
			// Default paragraph properties
			currentParagraphProperties = ParagraphProperties(
				alignment: .left,
				indent: 0,
				bulletType: nil,
				spacing: LineSpacing(before: 0, after: 0, line: 1.0)
			)
		}
		
		// Paragraph properties
		if elementName == "a:pPr" && isInParagraph {
			let alignment = parseAlignment(attributeDict["algn"])
			let indent = emuToPoints(Int(attributeDict["indent"] ?? "") ?? 0)
			
			currentParagraphProperties = ParagraphProperties(
				alignment: alignment,
				indent: indent,
				bulletType: nil, // Will be set if bullet found
				spacing: LineSpacing(before: 0, after: 0, line: 1.0)
			)
		}
		
		// Bullet/numbering
		if elementName == "a:buChar" && isInParagraph {
			if let char = attributeDict["char"] {
				currentParagraphProperties = ParagraphProperties(
					alignment: currentParagraphProperties?.alignment ?? .left,
					indent: currentParagraphProperties?.indent ?? 0,
					bulletType: .bullet(char),
					spacing: currentParagraphProperties?.spacing ?? LineSpacing(before: 0, after: 0, line: 1.0)
				)
			}
		}
		
		// Text run
		if elementName == "a:r" && isInParagraph {
			isInRun = true
			currentText = ""
			
			// Default run properties
			currentRunProperties = RunProperties(
				fontSize: nil,
				bold: false,
				italic: false,
				underline: false,
				fontFamily: nil,
				color: nil
			)
		}
		
		// Run properties
		if elementName == "a:rPr" && isInRun {
			let fontSize = attributeDict["sz"] != nil ? CGFloat(Int(attributeDict["sz"]!) ?? 1800) / 100.0 : nil
			let bold = attributeDict["b"] == "1"
			let italic = attributeDict["i"] == "1"
			let underline = attributeDict["u"] != nil
			
			currentRunProperties = RunProperties(
				fontSize: fontSize,
				bold: bold,
				italic: italic,
				underline: underline,
				fontFamily: nil, // Will be set if font found
				color: nil // Will be set if color found
			)
		}
		
		// Font
		if elementName == "a:latin" && isInRun {
			if let typeface = attributeDict["typeface"] {
				currentRunProperties = RunProperties(
					fontSize: currentRunProperties?.fontSize,
					bold: currentRunProperties?.bold ?? false,
					italic: currentRunProperties?.italic ?? false,
					underline: currentRunProperties?.underline ?? false,
					fontFamily: typeface,
					color: currentRunProperties?.color
				)
			}
		}
		
		// Solid fill color
		if elementName == "a:srgbClr" && isInRun {
			if let val = attributeDict["val"] {
				currentRunProperties = RunProperties(
					fontSize: currentRunProperties?.fontSize,
					bold: currentRunProperties?.bold ?? false,
					italic: currentRunProperties?.italic ?? false,
					underline: currentRunProperties?.underline ?? false,
					fontFamily: currentRunProperties?.fontFamily,
					color: val
				)
			}
		}
		
		// Text content
		if elementName == "a:t" {
			currentText = ""
		}
	}
	
	public func parser(_ parser: XMLParser, foundCharacters string: String) {
		if currentElement == "a:t" {
			currentText.append(string)
		}
	}
	
	public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		// End of text
		if elementName == "a:t" && isInRun {
			// Add text run with current properties
			let run = TextRun(
				text: currentText,
				properties: currentRunProperties ?? RunProperties(
					fontSize: nil,
					bold: false,
					italic: false,
					underline: false,
					fontFamily: nil,
					color: nil
				)
			)
			currentRuns.append(run)
		}
		
		// End of run
		if elementName == "a:r" {
			isInRun = false
		}
		
		// End of paragraph
		if elementName == "a:p" && isInParagraph {
			isInParagraph = false
			
			let paragraph = ParagraphInfo(
				runs: currentRuns,
				properties: currentParagraphProperties ?? ParagraphProperties(
					alignment: .left,
					indent: 0,
					bulletType: nil,
					spacing: LineSpacing(before: 0, after: 0, line: 1.0)
				)
			)
			currentParagraphs.append(paragraph)
			currentRuns = []
		}
		
		// End of text body
		if elementName == "p:txBody" && isInTextBody {
			isInTextBody = false
			
			let textBox = TextBoxInfo(
				paragraphs: currentParagraphs,
				bodyProperties: BodyProperties(
					margins: EdgeInsets(top: 3.6, left: 7.2, bottom: 3.6, right: 7.2),
					wrap: true,
					anchor: .top
				)
			)
			
			let shape = ShapeInfo(
				id: currentShapeId,
				frame: currentFrame,
				transform: currentTransform,
				type: .textBox(textBox)
			)
			shapes.append(shape)
			
			currentParagraphs = []
		}
		
		// End of shape
		if elementName == "p:sp" || elementName == "p:pic" || elementName == "p:graphicFrame" {
			isInShape = false
		}
	}
}
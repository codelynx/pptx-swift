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
			case shape(ShapeProperties)
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
	
	public struct ShapeProperties {
		let geometryType: String? // e.g., "rect", "roundRect", "ellipse"
		let fillColor: String?
		let gradientFill: GradientFill?
		let hasStroke: Bool // true if <a:ln/> or <a:ln> exists
		let strokeColor: String?
		let strokeWidth: CGFloat?
	}
	
	public struct GradientFill {
		let colors: [(color: String, position: CGFloat)]
		let angle: CGFloat?
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
	private var currentPictureRelId: String?
	private var currentShapeType: String = ""
	private var currentShapeProperties: ShapeProperties?
	private var currentGeometryType: String?
	private var currentFillColor: String?
	private var currentGradientColors: [(color: String, position: CGFloat)] = []
	private var hasShapeLine = false
	private var isInShape = false
	private var isInTextBody = false
	private var isInParagraph = false
	private var isInRun = false
	private var isInPicture = false
	private var isInShapeProperties = false
	private var isInGradientFill = false
	private var isInShapeStyle = false
	private var isInFillRef = false
	private var styleFillColor: String?
	
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
		currentPictureRelId = nil
		currentShapeType = ""
		isInShape = false
		isInTextBody = false
		isInParagraph = false
		isInRun = false
		isInPicture = false
		styleFillColor = nil
		currentFillColor = nil
		currentGeometryType = nil
		currentGradientColors = []
		hasShapeLine = false
		isInShapeProperties = false
		isInGradientFill = false
		isInShapeStyle = false
		isInFillRef = false
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
			
			// Track shape type
			if elementName == "p:pic" {
				isInPicture = true
				currentShapeType = "picture"
			} else if elementName == "p:sp" {
				currentShapeType = "shape"
			}
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
		
		// Shape properties
		if elementName == "p:spPr" && isInShape {
			isInShapeProperties = true
			hasShapeLine = false // Reset
			currentFillColor = nil
			currentGeometryType = nil
			currentGradientColors = []
		}
		
		// Preset geometry (shape type)
		if elementName == "a:prstGeom" && isInShapeProperties {
			currentGeometryType = attributeDict["prst"]
		}
		
		// Line/border element
		if elementName == "a:ln" && isInShapeProperties {
			hasShapeLine = true
		}
		
		// Solid fill
		if elementName == "a:solidFill" && isInShapeProperties {
			// Will get color in srgbClr
		}
		
		// Gradient fill
		if elementName == "a:gradFill" && isInShapeProperties {
			isInGradientFill = true
		}
		
		// Gradient stop
		if elementName == "a:gs" && isInGradientFill {
			if let posStr = attributeDict["pos"], let pos = Int(posStr) {
				// Store position as percentage (0-100)
				let position = CGFloat(pos) / 100000.0
				// We'll get the color in the next srgbClr or schemeClr element
				currentGradientColors.append(("pending", position))
			}
		}
		
		// Color value for shape fill or gradient
		if elementName == "a:srgbClr" && isInShapeProperties && !isInRun {
			if let val = attributeDict["val"] {
				if isInGradientFill && !currentGradientColors.isEmpty {
					// Update the last gradient color
					let lastIndex = currentGradientColors.count - 1
					currentGradientColors[lastIndex].color = val
				} else {
					currentFillColor = val
				}
			}
		}
		
		// Scheme color (theme color)
		if elementName == "a:schemeClr" && isInShapeProperties {
			if let val = attributeDict["val"] {
				// Map common scheme colors to approximate values
				let color: String
				switch val {
				case "accent1": color = "5B9BD5" // Blue
				case "accent2": color = "ED7D31" // Orange
				case "accent3": color = "A5A5A5" // Gray
				case "accent4": color = "FFC000" // Yellow
				case "accent5": color = "5B9BD5" // Blue
				case "accent6": color = "70AD47" // Green
				default: color = "808080" // Default gray
				}
				
				if isInGradientFill && !currentGradientColors.isEmpty {
					// Update the last gradient color
					let lastIndex = currentGradientColors.count - 1
					currentGradientColors[lastIndex].color = color
				} else {
					currentFillColor = color
				}
			}
		}
		
		// Shape style
		if elementName == "p:style" && isInShape {
			isInShapeStyle = true
			styleFillColor = nil
		}
		
		// Fill reference in style
		if elementName == "a:fillRef" && isInShapeStyle {
			// The schemeClr will be in a child element
			// We're now inside a fillRef, the next schemeClr should set our fill
			isInFillRef = true
		}
		
		// Scheme color in style - only process if we're inside a fillRef
		if elementName == "a:schemeClr" && isInShapeStyle && isInFillRef {
			if let val = attributeDict["val"] {
				// Map scheme color to actual color
				switch val {
				case "accent1": styleFillColor = "5B9BD5" // Blue
				case "accent2": styleFillColor = "ED7D31" // Orange
				case "accent3": styleFillColor = "A5A5A5" // Gray
				case "accent4": 
					styleFillColor = "FFC000" // Yellow
				case "accent5": styleFillColor = "5B9BD5" // Blue
				case "accent6": styleFillColor = "70AD47" // Green
				case "lt1": styleFillColor = nil // Light 1 - typically white/transparent
				default: break // Don't reset for other scheme colors
				}
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
		
		// Picture blip (image reference)
		if elementName == "a:blip" && isInPicture {
			if let embed = attributeDict["r:embed"] {
				currentPictureRelId = embed
			}
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
		
		// End of gradient fill
		if elementName == "a:gradFill" {
			isInGradientFill = false
		}
		
		// End of fill reference
		if elementName == "a:fillRef" {
			isInFillRef = false
		}
		
		// End of style
		if elementName == "p:style" {
			isInShapeStyle = false
			isInFillRef = false // Reset just in case
		}
		
		// End of shape properties
		if elementName == "p:spPr" {
			isInShapeProperties = false
		}
		
		// End of shape
		if elementName == "p:sp" || elementName == "p:pic" || elementName == "p:graphicFrame" {
			// Handle picture elements
			if elementName == "p:pic" && isInPicture {
				if let relId = currentPictureRelId {
					let picture = PictureInfo(imageRelId: relId, frame: currentFrame)
					let shape = ShapeInfo(
						id: currentShapeId,
						frame: currentFrame,
						transform: currentTransform,
						type: .picture(picture)
					)
					shapes.append(shape)
				}
				isInPicture = false
				currentPictureRelId = nil
			}
			// Handle regular shapes
			else if elementName == "p:sp" && currentShapeType == "shape" {
				// Check if we need to create a background shape
				let fillColor = currentFillColor ?? styleFillColor
				let hasGradient = !currentGradientColors.isEmpty && currentGradientColors.allSatisfy({ $0.color != "pending" })
				
				
				// Create a background shape if:
				// 1. The shape has no text (pure shape), OR
				// 2. The shape has text AND has a fill color or gradient
				if currentParagraphs.isEmpty || fillColor != nil || hasGradient {
					// Create gradient fill if we have gradient colors
					let gradientFill: GradientFill?
					if hasGradient {
						gradientFill = GradientFill(
							colors: currentGradientColors,
							angle: nil // TODO: Parse gradient angle
						)
					} else {
						gradientFill = nil
					}
					
					// Only create the shape if it's a pure shape OR has actual fill
					if currentParagraphs.isEmpty || fillColor != nil || gradientFill != nil {
						let shapeProps = ShapeProperties(
							geometryType: currentGeometryType,
							fillColor: fillColor,
							gradientFill: gradientFill,
							hasStroke: hasShapeLine,
							strokeColor: nil, // TODO: Parse stroke color
							strokeWidth: nil  // TODO: Parse stroke width
						)
						let shape = ShapeInfo(
							id: currentShapeId,
							frame: currentFrame,
							transform: currentTransform,
							type: .shape(shapeProps)
						)
						
						// Insert background shape BEFORE the text box if we have text
						if !currentParagraphs.isEmpty && !shapes.isEmpty {
							// Find the text box we just added and insert before it
							let lastIndex = shapes.count - 1
							if case .textBox = shapes[lastIndex].type, shapes[lastIndex].id == currentShapeId {
								shapes.insert(shape, at: lastIndex)
							} else {
								shapes.append(shape)
							}
						} else {
							shapes.append(shape)
						}
					}
				}
			}
			
			isInShape = false
			currentShapeType = ""
			currentShapeProperties = nil
			hasShapeLine = false
			styleFillColor = nil // Reset style fill color
		}
	}
}
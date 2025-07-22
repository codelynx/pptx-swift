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
			case table(TableInfo)
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
	
	public struct TableInfo {
		public let rows: [[TableCell]]
		public let columnWidths: [CGFloat]
		public let rowHeights: [CGFloat]
	}
	
	public struct TableCell {
		public let text: String
		public let paragraphs: [ParagraphInfo]
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
	private var currentPlaceholderType: String?
	
	// Table parsing state
	private var isInGraphicFrame = false
	private var isInTable = false
	private var isInTableRow = false
	private var isInTableCell = false
	private var currentTableRows: [[TableCell]] = []
	private var currentTableRow: [TableCell] = []
	private var currentTableCellParagraphs: [ParagraphInfo] = []
	private var currentColumnWidths: [CGFloat] = []
	private var currentRowHeights: [CGFloat] = []
	
	// EMU to points conversion (1 point = 12700 EMUs)
	private let emuPerPoint: CGFloat = 12700
	
	// Theme for resolving colors
	private var theme: Theme?
	
	/// Parse slide XML to extract detailed shape and text information
	public func parseSlide(data: Data, theme: Theme? = nil) throws -> [ShapeInfo] {
		shapes.removeAll()
		resetState()
		self.theme = theme
		
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
		isInGraphicFrame = false
		isInTable = false
		isInTableRow = false
		isInTableCell = false
		currentTableRows = []
		currentTableRow = []
		currentTableCellParagraphs = []
		currentColumnWidths = []
		currentRowHeights = []
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
		if elementName == "p:sp" || elementName == "p:pic" || elementName == "p:graphicFrame" || elementName == "p:cxnSp" {
			isInShape = true
			currentShapeId = "shape\(shapes.count + 1)"
			currentFrame = .zero
			currentTransform = .identity
			
			// Track shape type
			if elementName == "p:pic" {
				isInPicture = true
				currentShapeType = "picture"
			} else if elementName == "p:sp" || elementName == "p:cxnSp" {
				currentShapeType = "shape"
			} else if elementName == "p:graphicFrame" {
				isInGraphicFrame = true
				currentShapeType = "graphicFrame"
			}
		}
		
		// Non-visual properties (contains shape ID)
		if elementName == "p:cNvPr" && isInShape {
			if let id = attributeDict["id"] {
				currentShapeId = "shape\(id)"
			}
		}
		
		// Placeholder properties - set default positions
		if elementName == "p:ph" && isInShape {
			if let type = attributeDict["type"] {
				currentPlaceholderType = type
				switch type {
				case "ctrTitle":
					// Default center title position
					currentFrame = CGRect(x: 120, y: 88, width: 720, height: 188)
				case "title":
					// Default title position (left-aligned)
					currentFrame = CGRect(x: 66, y: 60, width: 828, height: 104)
				case "subTitle":
					// Default subtitle position
					currentFrame = CGRect(x: 120, y: 310, width: 720, height: 100)
				case "body":
					// Default body position
					currentFrame = CGRect(x: 120, y: 188, width: 720, height: 300)
				default:
					// Default fallback
					currentFrame = CGRect(x: 50, y: 50, width: 500, height: 100)
				}
			} else if let idx = attributeDict["idx"] {
				// Content placeholder without specific type
				let size = attributeDict["sz"] ?? "full"
				
				if size == "half" {
					// Two-column layout
					switch idx {
					case "1":
						// Left column
						currentFrame = CGRect(x: 66, y: 170, width: 404, height: 380)
					case "2":
						// Right column
						currentFrame = CGRect(x: 490, y: 170, width: 404, height: 380)
					default:
						currentFrame = CGRect(x: 66, y: 170, width: 828, height: 380)
					}
				} else {
					// Full width
					currentFrame = CGRect(x: 66, y: 170, width: 828, height: 380)
				}
				currentPlaceholderType = "body"
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
				// Resolve color from theme if available
				let color: String
				if let theme = self.theme,
				   let themeColor = theme.colorScheme.color(for: val) {
					color = themeColor.hexValue
				} else {
					// Fallback to hardcoded values if no theme
					switch val {
					case "accent1": color = "5B9BD5" // Blue
					case "accent2": color = "ED7D31" // Orange
					case "accent3": color = "A5A5A5" // Gray
					case "accent4": color = "FFC000" // Yellow
					case "accent5": color = "5B9BD5" // Blue
					case "accent6": color = "70AD47" // Green
					default: color = "808080" // Default gray
					}
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
				// Resolve color from theme if available
				if let theme = self.theme,
				   let themeColor = theme.colorScheme.color(for: val) {
					styleFillColor = themeColor.hexValue
				} else {
					// Fallback to hardcoded values if no theme
					switch val {
					case "accent1": styleFillColor = "5B9BD5" // Blue
					case "accent2": styleFillColor = "ED7D31" // Orange
					case "accent3": styleFillColor = "A5A5A5" // Gray
					case "accent4": styleFillColor = "FFC000" // Yellow
					case "accent5": styleFillColor = "5B9BD5" // Blue
					case "accent6": styleFillColor = "70AD47" // Green
					case "lt1": styleFillColor = nil // Light 1 - typically white/transparent
					default: break // Don't reset for other scheme colors
					}
				}
			}
		}
		
		// Text body
		if (elementName == "p:txBody" && isInShape) || (elementName == "a:txBody" && isInTableCell) {
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
			
			// Default paragraph properties based on placeholder type
			var defaultAlignment: NSTextAlignment = .left
			var defaultBulletType: BulletType? = nil
			
			if let placeholderType = currentPlaceholderType {
				switch placeholderType {
				case "ctrTitle", "subTitle":
					defaultAlignment = .center
				case "body":
					// Body text typically has bullets in presentations
					// But don't add default bullets if we're parsing a numbered list
					// (this will be overridden by buAutoNum if present)
					defaultBulletType = .bullet("•")
				default:
					defaultAlignment = .left
				}
			}
			
			currentParagraphProperties = ParagraphProperties(
				alignment: defaultAlignment,
				indent: 0,
				bulletType: defaultBulletType,
				spacing: LineSpacing(before: 0, after: 0, line: 1.0)
			)
		}
		
		// Paragraph properties
		if elementName == "a:pPr" && isInParagraph {
			var alignment = parseAlignment(attributeDict["algn"])
			let indent = emuToPoints(Int(attributeDict["indent"] ?? "") ?? 0)
			
			// If no alignment specified and we have a placeholder type, use defaults
			if attributeDict["algn"] == nil && currentPlaceholderType != nil {
				switch currentPlaceholderType {
				case "ctrTitle", "subTitle":
					alignment = .center
				default:
					break
				}
			}
			
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
		
		// Auto-numbering
		if elementName == "a:buAutoNum" && isInParagraph {
			let numberType = attributeDict["type"] ?? "arabicPeriod"
			// For now, we'll track paragraph count to generate numbers
			// In a real implementation, this would need to track numbering state
			currentParagraphProperties = ParagraphProperties(
				alignment: currentParagraphProperties?.alignment ?? .left,
				indent: currentParagraphProperties?.indent ?? 0,
				bulletType: .number("\(currentParagraphs.count + 1)"), // Simple numbering
				spacing: currentParagraphProperties?.spacing ?? LineSpacing(before: 0, after: 0, line: 1.0)
			)
		}
		
		// Text run
		if elementName == "a:r" && isInParagraph {
			isInRun = true
			currentText = ""
			
			// Default run properties based on placeholder type
			var defaultFontSize: CGFloat? = nil
			if let placeholderType = currentPlaceholderType {
				switch placeholderType {
				case "ctrTitle":
					defaultFontSize = 60.0 // 60pt for main titles
				case "subTitle":
					defaultFontSize = 32.0 // 32pt for subtitles
				default:
					defaultFontSize = 18.0 // Default body text
				}
			}
			
			currentRunProperties = RunProperties(
				fontSize: defaultFontSize,
				bold: false,
				italic: false,
				underline: false,
				fontFamily: nil,
				color: nil
			)
		}
		
		// Run properties
		if elementName == "a:rPr" && isInRun {
			var fontSize = attributeDict["sz"] != nil ? CGFloat(Int(attributeDict["sz"]!) ?? 1800) / 100.0 : nil
			let bold = attributeDict["b"] == "1"
			let italic = attributeDict["i"] == "1"
			let underline = attributeDict["u"] != nil
			
			// If no font size specified and we have a placeholder type, use defaults
			if fontSize == nil && currentPlaceholderType != nil {
				switch currentPlaceholderType {
				case "ctrTitle":
					fontSize = 60.0 // 60pt for main titles
				case "subTitle":
					fontSize = 32.0 // 32pt for subtitles
				default:
					fontSize = 18.0 // Default body text
				}
			}
			
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
		
		// Table detection
		if elementName == "a:tbl" && isInGraphicFrame {
			isInTable = true
			currentTableRows = []
			currentColumnWidths = []
			currentRowHeights = []
		}
		
		// Table grid column
		if elementName == "a:gridCol" && isInTable {
			if let w = attributeDict["w"], let width = Int(w) {
				currentColumnWidths.append(emuToPoints(width))
			}
		}
		
		// Table row
		if elementName == "a:tr" && isInTable {
			isInTableRow = true
			currentTableRow = []
			if let h = attributeDict["h"], let height = Int(h) {
				currentRowHeights.append(emuToPoints(height))
			}
		}
		
		// Table cell
		if elementName == "a:tc" && isInTableRow {
			isInTableCell = true
			currentTableCellParagraphs = []
			// Reset text parsing state for cell content
			currentParagraphs = []
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
		if (elementName == "p:txBody" || elementName == "a:txBody") && isInTextBody {
			isInTextBody = false
			// Don't create shape here - wait until p:sp ends to determine shape type
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
		
		// End of table cell
		if elementName == "a:tc" && isInTableCell {
			// Collect all text from paragraphs
			var cellText = ""
			for (index, paragraph) in currentParagraphs.enumerated() {
				for run in paragraph.runs {
					cellText += run.text
				}
				if index < currentParagraphs.count - 1 {
					cellText += "\n"
				}
			}
			
			let cell = TableCell(
				text: cellText,
				paragraphs: currentParagraphs
			)
			currentTableRow.append(cell)
			isInTableCell = false
			currentParagraphs = []
		}
		
		// End of table row
		if elementName == "a:tr" && isInTableRow {
			currentTableRows.append(currentTableRow)
			isInTableRow = false
			currentTableRow = []
		}
		
		// End of table
		if elementName == "a:tbl" && isInTable {
			// Table parsing complete, will be added when graphicFrame ends
		}
		
		// End of shape
		if elementName == "p:sp" || elementName == "p:pic" || elementName == "p:graphicFrame" || elementName == "p:cxnSp" {
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
			else if elementName == "p:sp" || elementName == "p:cxnSp" {
				// Determine if this is a shape with geometry or just a text box
				let hasGeometry = currentGeometryType != nil
				let hasText = !currentParagraphs.isEmpty
				let fillColor = currentFillColor ?? styleFillColor
				let hasGradient = !currentGradientColors.isEmpty && currentGradientColors.allSatisfy({ $0.color != "pending" })
				
				if hasGeometry {
					// This is a shape with preset geometry
					let gradientFill: GradientFill?
					if hasGradient {
						gradientFill = GradientFill(
							colors: currentGradientColors,
							angle: nil // TODO: Parse gradient angle
						)
					} else {
						gradientFill = nil
					}
					
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
					shapes.append(shape)
					
					// If the shape also has text, add a text box overlay
					if hasText {
						let textBox = TextBoxInfo(
							paragraphs: currentParagraphs,
							bodyProperties: BodyProperties(
								margins: EdgeInsets(top: 3.6, left: 7.2, bottom: 3.6, right: 7.2),
								wrap: true,
								anchor: .top
							)
						)
						let textShape = ShapeInfo(
							id: "\(currentShapeId)_text",
							frame: currentFrame,
							transform: currentTransform,
							type: .textBox(textBox)
						)
						shapes.append(textShape)
					}
				} else if hasText {
					// This is just a text box without geometry
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
				}
			}
			// Handle graphic frame (tables)
			else if elementName == "p:graphicFrame" && isInGraphicFrame {
				if isInTable && !currentTableRows.isEmpty {
					let table = TableInfo(
						rows: currentTableRows,
						columnWidths: currentColumnWidths,
						rowHeights: currentRowHeights
					)
					let shape = ShapeInfo(
						id: currentShapeId,
						frame: currentFrame,
						transform: currentTransform,
						type: .table(table)
					)
					shapes.append(shape)
				}
				isInGraphicFrame = false
				isInTable = false
			}
			
			isInShape = false
			currentShapeType = ""
			currentShapeProperties = nil
			hasShapeLine = false
			styleFillColor = nil // Reset style fill color
			currentPlaceholderType = nil // Reset placeholder type
			currentGeometryType = nil // Reset geometry type
			currentParagraphs = [] // Clear paragraphs
		}
	}
}
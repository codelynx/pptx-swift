import Foundation
import CoreGraphics
import ZIPFoundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Main renderer for PPTX slides
public class SlideRenderer {
	private let context: RenderingContext
	private let shapeRenderer: ShapeRenderer
	private let textRenderer: TextRenderer
	private let imageRenderer: ImageRenderer
	private var archive: Archive?
	private var document: PPTXDocument?
	
	public init(context: RenderingContext, archive: Archive? = nil, document: PPTXDocument? = nil) {
		self.context = context
		self.archive = archive
		self.document = document
		self.shapeRenderer = ShapeRenderer(context: context)
		self.textRenderer = TextRenderer(context: context)
		self.imageRenderer = ImageRenderer(context: context)
	}
	
	/// Set the archive for loading resources
	public func setArchive(_ archive: Archive?) {
		self.archive = archive
	}
	
	/// Set the document for theme resolution
	public func setDocument(_ document: PPTXDocument?) {
		self.document = document
	}
	
	/// Render a slide to a CGImage
	public func render(slide: Slide, archive: Archive? = nil) throws -> CGImage {
		// Use provided archive or the one set during init
		let workingArchive = archive ?? self.archive
		// Create graphics context
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
		
		let pixelWidth = Int(context.size.width * context.scale)
		let pixelHeight = Int(context.size.height * context.scale)
		
		guard let cgContext = CGContext(
			data: nil,
			width: pixelWidth,
			height: pixelHeight,
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: colorSpace,
			bitmapInfo: bitmapInfo
		) else {
			throw RenderingError.contextCreationFailed
		}
		
		// Flip coordinate system for both iOS and macOS
		// UIKit and AppKit both expect origin at top-left, while Core Graphics has origin at bottom-left
		cgContext.translateBy(x: 0, y: CGFloat(pixelHeight))
		cgContext.scaleBy(x: 1, y: -1)
		
		// Apply scale for retina
		cgContext.scaleBy(x: context.scale, y: context.scale)
		
		// Render background
		if context.options.renderBackground {
			renderBackground(in: cgContext)
		}
		
		// Parse and render slide content
		let renderTree = try buildRenderTree(from: slide, archive: workingArchive)
		try renderElements(renderTree, in: cgContext)
		
		// Create final image
		guard let image = cgContext.makeImage() else {
			throw RenderingError.imageCreationFailed
		}
		
		return image
	}
	
	/// Render slide background
	private func renderBackground(in context: CGContext) {
		// Default white background
		context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
		context.fill(CGRect(origin: .zero, size: self.context.size))
	}
	
	/// Build render tree from slide data
	private func buildRenderTree(from slide: Slide, archive: Archive?) throws -> [RenderElement] {
		var elements: [RenderElement] = []
		
		// Check if we have raw XML data to parse
		if let xmlData = slide.rawXMLData {
			print("DEBUG: Parsing XML data of size: \(xmlData.count) bytes")
			// Parse the slide XML to get detailed layout information
			let parser = SlideXMLParser()
			let shapes = try parser.parseSlide(data: xmlData, theme: document?.theme)
			print("DEBUG: Parsed \(shapes.count) shapes from XML")
			
			// Convert parsed shapes to render elements
			// First pass: collect shapes by ID to check for text boxes with backgrounds
			var shapesByID: [String: SlideXMLParser.ShapeInfo] = [:]
			for shape in shapes {
				shapesByID[shape.id] = shape
			}
			
			// Second pass: render elements
			var processedIDs: Set<String> = []
			
			for shape in shapes {
				// Skip if already processed
				if processedIDs.contains(shape.id) {
					continue
				}
				
				print("DEBUG: Processing shape id: \(shape.id), type: \(shape.type), frame: \(shape.frame)")
				
				switch shape.type {
				case .textBox(let textBox):
					// Check if there's a corresponding shape with the same ID (background)
					let backgroundShape = shapes.first { otherShape in
						if case .shape = otherShape.type {
							return otherShape.id == shape.id && otherShape.frame == shape.frame
						}
						return false
					}
					
					// If there's a background shape, render it first
					if let bgShape = backgroundShape, case .shape(let bgShapeData) = bgShape.type {
						let bgElement = createShapeElement(
							from: bgShapeData,
							frame: bgShape.frame,
							transform: bgShape.transform
						)
						elements.append(bgElement)
						processedIDs.insert(bgShape.id)
					}
					
					// Create text elements from the text box
					let textElements = createTextElements(from: textBox, frame: shape.frame, transform: shape.transform)
					elements.append(contentsOf: textElements)
					processedIDs.insert(shape.id)
					
				case .picture(let picture):
					// Try to load the actual image
					var imageData: ImageData
					
					// Find the relationship for this image
					if let relationship = slide.relationships.first(where: { $0.id == picture.imageRelId }) {
						// Try to load the image from archive
						if let archive = archive {
							do {
								if let cgImage = try imageRenderer.loadImageSync(from: relationship, in: archive) {
									imageData = ImageData(cgImage: cgImage)
								} else {
									imageData = ImageData(placeholder: "Failed to load: \(relationship.target)")
								}
							} catch {
								// Fall back to placeholder on error
								imageData = ImageData(placeholder: "Error loading: \(relationship.target)")
							}
						} else {
							imageData = ImageData(placeholder: "No archive: \(picture.imageRelId)")
						}
					} else {
						imageData = ImageData(placeholder: "Missing relationship: \(picture.imageRelId)")
					}
					
					let imageElement = RenderElement(
						type: .image,
						frame: shape.frame,
						content: .image(imageData),
						transform: shape.transform
					)
					elements.append(imageElement)
					processedIDs.insert(shape.id)
					
				case .shape(let shapeData):
					// Skip if this is a background for a text box (already processed)
					if !processedIDs.contains(shape.id) {
						// Create shape element
						let shapeElement = createShapeElement(
							from: shapeData,
							frame: shape.frame,
							transform: shape.transform
						)
						elements.append(shapeElement)
						processedIDs.insert(shape.id)
					}
					
				case .table(let tableInfo):
					// Create table element
					let tableElement = createTableElement(
						from: tableInfo,
						frame: shape.frame,
						transform: shape.transform
					)
					elements.append(tableElement)
					processedIDs.insert(shape.id)
				}
			}
		} else {
			// Fallback to simple rendering if no XML data available
			elements = createSimpleElements(from: slide)
		}
		
		return elements
	}
	
	/// Create text render elements from parsed text box
	private func createTextElements(from textBox: SlideXMLParser.TextBoxInfo, frame: CGRect, transform: CGAffineTransform) -> [RenderElement] {
		var elements: [RenderElement] = []
		var yOffset: CGFloat = frame.origin.y + textBox.bodyProperties.margins.top
		
		for paragraph in textBox.paragraphs {
			// Combine all runs in the paragraph
			var paragraphText = ""
			var fontSize: CGFloat = 18 // Default
			var fontFamily: String? = nil
			var isBold = false
			var color: CGColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
			
			for run in paragraph.runs {
				paragraphText += run.text
				
				// Use properties from first run with defined values
				if let runFontSize = run.properties.fontSize {
					fontSize = runFontSize
				}
				if let runFontFamily = run.properties.fontFamily {
					fontFamily = runFontFamily
				}
				if run.properties.bold {
					isBold = true
				}
				if let colorHex = run.properties.color {
					// Parse hex color
					color = parseHexColor(colorHex) ?? color
				}
			}
			
			print("DEBUG: Paragraph text: '\(paragraphText)', fontSize: \(fontSize)")
			
			if !paragraphText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				// Create appropriate font
				let font: PlatformFont
				if let fontName = fontFamily {
					font = PlatformFont(name: fontName, size: fontSize) ?? PlatformFont.systemFont(ofSize: fontSize)
				} else {
					font = isBold ? PlatformFont.boldSystemFont(ofSize: fontSize) : PlatformFont.systemFont(ofSize: fontSize)
				}
				
				// Add bullet if present
				if let bulletType = paragraph.properties.bulletType {
					switch bulletType {
					case .bullet(let char):
						paragraphText = "\(char) \(paragraphText)"
					case .number(let num):
						paragraphText = "\(num). \(paragraphText)"
					case .none:
						break
					}
				}
				
				// Create text style
				let textStyle = TextStyle(
					font: font,
					color: color,
					alignment: paragraph.properties.alignment
				)
				
				// Calculate text height (approximate)
				let lineHeight = fontSize * 1.2
				let lineCount = max(1, paragraphText.components(separatedBy: .newlines).count)
				let textHeight = lineHeight * CGFloat(lineCount)
				
				// Create render element
				let textX = frame.origin.x + textBox.bodyProperties.margins.left + paragraph.properties.indent
				let textWidth = max(10, frame.width - textBox.bodyProperties.margins.left - textBox.bodyProperties.margins.right - paragraph.properties.indent)
				
				let textFrame = CGRect(
					x: textX,
					y: yOffset,
					width: textWidth,
					height: textHeight
				)
				print("DEBUG: Creating text element with frame: \(textFrame), text: '\(paragraphText)'")
				
				let element = RenderElement(
					type: .text,
					frame: textFrame,
					content: .text(paragraphText, textStyle),
					transform: transform
				)
				elements.append(element)
				
				yOffset += textHeight + paragraph.properties.spacing.after
			}
		}
		
		return elements
	}
	
	/// Parse hex color string to CGColor
	private func parseHexColor(_ hex: String) -> CGColor? {
		let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int: UInt64 = 0
		Scanner(string: hex).scanHexInt64(&int)
		let a, r, g, b: UInt64
		switch hex.count {
		case 6: // RGB
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			return nil
		}
		
		return CGColor(
			red: CGFloat(r) / 255,
			green: CGFloat(g) / 255,
			blue: CGFloat(b) / 255,
			alpha: CGFloat(a) / 255
		)
	}
	
	/// Create shape element from parsed shape data
	private func createShapeElement(from shapeProps: SlideXMLParser.ShapeProperties, frame: CGRect, transform: CGAffineTransform) -> RenderElement {
		// Determine shape type
		let shapeType: ShapeData.ShapeType
		switch shapeProps.geometryType {
		case "rect", "rectangle":
			shapeType = .rectangle
		case "ellipse", "circle":
			shapeType = .ellipse
		case "roundRect":
			shapeType = .custom(ShapeRenderer.createRoundedRectPath(cornerRadius: 10, in: frame))
		case "star5":
			shapeType = .custom(ShapeRenderer.createStarPath(points: 5, in: frame))
		case "star4":
			shapeType = .custom(ShapeRenderer.createStarPath(points: 4, in: frame))
		case "star6":
			shapeType = .custom(ShapeRenderer.createStarPath(points: 6, in: frame))
		case "star8":
			shapeType = .custom(ShapeRenderer.createStarPath(points: 8, in: frame))
		case "heart":
			shapeType = .custom(createHeartPath(in: frame))
		case "dodecagon":
			shapeType = .custom(createPolygonPath(sides: 12, in: frame))
		case "octagon":
			shapeType = .custom(createPolygonPath(sides: 8, in: frame))
		case "hexagon":
			shapeType = .custom(createPolygonPath(sides: 6, in: frame))
		case "pentagon":
			shapeType = .custom(createPolygonPath(sides: 5, in: frame))
		case "triangle":
			shapeType = .custom(createPolygonPath(sides: 3, in: frame))
		case "straightConnector1", "line":
			shapeType = .custom(createLineConnectorPath(in: frame))
		case "rightArrow", "arrow":
			shapeType = .custom(ShapeRenderer.createArrowPath(in: frame))
		case "leftArrow":
			shapeType = .custom(createLeftArrowPath(in: frame))
		case "upArrow":
			shapeType = .custom(createUpArrowPath(in: frame))
		case "downArrow":
			shapeType = .custom(createDownArrowPath(in: frame))
		case "leftRightArrow":
			shapeType = .custom(createLeftRightArrowPath(in: frame))
		case "upDownArrow":
			shapeType = .custom(createUpDownArrowPath(in: frame))
		default:
			// Default to rectangle for unknown shapes
			shapeType = .rectangle
		}
		
		// Create fill style
		let fillStyle: FillStyle?
		
		// Special case: connectors typically have no fill
		if shapeProps.geometryType?.contains("Connector") == true || shapeProps.geometryType == "line" {
			fillStyle = nil
		} else if let gradientFill = shapeProps.gradientFill, !gradientFill.colors.isEmpty {
			// Create gradient fill
			let colors = gradientFill.colors.compactMap { colorInfo -> CGColor? in
				parseHexColor(colorInfo.color)
			}
			let locations = gradientFill.colors.map { $0.position }
			
			if !colors.isEmpty {
				// Determine gradient direction based on angle or default to vertical
				let angle = gradientFill.angle ?? 90.0 // Default to vertical gradient
				let radians = angle * .pi / 180.0
				
				// Calculate gradient endpoints based on angle
				let startPoint: CGPoint
				let endPoint: CGPoint
				
				switch angle {
				case 0: // Horizontal left to right
					startPoint = CGPoint(x: 0, y: 0.5)
					endPoint = CGPoint(x: 1, y: 0.5)
				case 90: // Vertical top to bottom
					startPoint = CGPoint(x: 0.5, y: 0)
					endPoint = CGPoint(x: 0.5, y: 1)
				case 180: // Horizontal right to left
					startPoint = CGPoint(x: 1, y: 0.5)
					endPoint = CGPoint(x: 0, y: 0.5)
				case 270: // Vertical bottom to top
					startPoint = CGPoint(x: 0.5, y: 1)
					endPoint = CGPoint(x: 0.5, y: 0)
				default: // Diagonal based on angle
					let dx = cos(radians)
					let dy = sin(radians)
					startPoint = CGPoint(x: 0.5 - dx * 0.5, y: 0.5 - dy * 0.5)
					endPoint = CGPoint(x: 0.5 + dx * 0.5, y: 0.5 + dy * 0.5)
				}
				
				fillStyle = .gradient(GradientFill(
					colors: colors,
					locations: locations,
					startPoint: startPoint,
					endPoint: endPoint
				))
			} else {
				fillStyle = nil
			}
		} else if let fillColor = shapeProps.fillColor {
			// Solid fill
			fillStyle = parseHexColor(fillColor).map { FillStyle.solid($0) }
		} else {
			fillStyle = nil
		}
		
		// Create stroke style
		let strokeStyle: StrokeStyle?
		if shapeProps.hasStroke {
			// Default stroke if no color specified
			let strokeColor = shapeProps.strokeColor.flatMap { parseHexColor($0) } ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1)
			strokeStyle = StrokeStyle(color: strokeColor, width: shapeProps.strokeWidth ?? 1.0)
		} else {
			strokeStyle = nil
		}
		
		// Create shape data
		let shape = ShapeData(
			type: shapeType,
			fill: fillStyle,
			stroke: strokeStyle
		)
		
		return RenderElement(
			type: .shape,
			frame: frame,
			content: .shape(shape),
			transform: transform
		)
	}
	
	/// Create table element
	private func createTableElement(from tableInfo: SlideXMLParser.TableInfo, frame: CGRect, transform: CGAffineTransform) -> RenderElement {
		var elements: [RenderElement] = []
		
		// Calculate cell dimensions
		let numColumns = tableInfo.columnWidths.count
		let numRows = tableInfo.rows.count
		
		guard numColumns > 0 && numRows > 0 else {
			// Return empty group if no data
			return RenderElement(
				type: .group,
				frame: frame,
				content: .group([]),
				transform: transform
			)
		}
		
		// Calculate cell sizes based on table frame and column/row dimensions
		let totalWidth = tableInfo.columnWidths.reduce(0, +)
		let totalHeight = tableInfo.rowHeights.reduce(0, +)
		let scaleX = frame.width / totalWidth
		let scaleY = frame.height / totalHeight
		
		// Draw table cells
		var yOffset: CGFloat = frame.origin.y
		
		for (rowIndex, row) in tableInfo.rows.enumerated() {
			let rowHeight = rowIndex < tableInfo.rowHeights.count ? tableInfo.rowHeights[rowIndex] * scaleY : frame.height / CGFloat(numRows)
			var xOffset: CGFloat = frame.origin.x
			
			for (colIndex, cell) in row.enumerated() {
				let colWidth = colIndex < tableInfo.columnWidths.count ? tableInfo.columnWidths[colIndex] * scaleX : frame.width / CGFloat(numColumns)
				
				// Create cell background with border
				let cellFrame = CGRect(x: xOffset, y: yOffset, width: colWidth, height: rowHeight)
				
				// Determine cell fill color based on row (header row is darker)
				let fillColor: CGColor
				if rowIndex == 0 {
					// Header row - use theme accent color or default blue
					fillColor = CGColor(red: 0.31, green: 0.506, blue: 0.741, alpha: 1.0) // #4F81BD
				} else {
					// Alternating row colors
					fillColor = rowIndex % 2 == 1 ? 
						CGColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) : 
						CGColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
				}
				
				// Create cell background shape
				let cellShape = ShapeData(
					type: .rectangle,
					fill: .solid(fillColor),
					stroke: StrokeStyle(color: CGColor(gray: 0.7, alpha: 1.0), width: 0.5)
				)
				
				let cellElement = RenderElement(
					type: .shape,
					frame: cellFrame,
					content: .shape(cellShape),
					transform: .identity
				)
				elements.append(cellElement)
				
				// Add text content
				if !cell.text.isEmpty {
					let textColor = rowIndex == 0 ? CGColor.white : CGColor.black
					let fontSize: CGFloat = 12
					let font = PlatformFont.systemFont(ofSize: fontSize)
					let textStyle = TextStyle(
						font: font,
						color: textColor,
						alignment: .center
					)
					
					// Add padding to text
					let textFrame = cellFrame.insetBy(dx: 4, dy: 2)
					
					let textElement = RenderElement(
						type: .text,
						frame: textFrame,
						content: .text(cell.text, textStyle),
						transform: .identity
					)
					elements.append(textElement)
				}
				
				xOffset += colWidth
			}
			
			yOffset += rowHeight
		}
		
		// Return group element containing all table elements
		return RenderElement(
			type: .group,
			frame: frame,
			content: .group(elements),
			transform: transform
		)
	}
	
	/// Create heart shape path
	private func createHeartPath(in bounds: CGRect) -> CGPath {
		let path = CGMutablePath()
		
		let width = bounds.width
		let height = bounds.height
		let x = bounds.origin.x
		let y = bounds.origin.y
		
		// Heart shape using bezier curves
		path.move(to: CGPoint(x: x + width * 0.5, y: y + height * 0.2))
		
		// Left curve
		path.addCurve(to: CGPoint(x: x, y: y + height * 0.5),
					  control1: CGPoint(x: x + width * 0.3, y: y),
					  control2: CGPoint(x: x, y: y + height * 0.3))
		
		// Bottom point
		path.addCurve(to: CGPoint(x: x + width * 0.5, y: y + height),
					  control1: CGPoint(x: x, y: y + height * 0.7),
					  control2: CGPoint(x: x + width * 0.3, y: y + height * 0.9))
		
		// Right curve
		path.addCurve(to: CGPoint(x: x + width, y: y + height * 0.5),
					  control1: CGPoint(x: x + width * 0.7, y: y + height * 0.9),
					  control2: CGPoint(x: x + width, y: y + height * 0.7))
		
		// Top right
		path.addCurve(to: CGPoint(x: x + width * 0.5, y: y + height * 0.2),
					  control1: CGPoint(x: x + width, y: y + height * 0.3),
					  control2: CGPoint(x: x + width * 0.7, y: y))
		
		path.closeSubpath()
		return path
	}
	
	/// Create polygon path with specified number of sides
	private func createPolygonPath(sides: Int, in bounds: CGRect) -> CGPath {
		let path = CGMutablePath()
		
		let center = CGPoint(x: bounds.midX, y: bounds.midY)
		let radius = min(bounds.width, bounds.height) / 2
		
		let angleStep = (2 * CGFloat.pi) / CGFloat(sides)
		let startAngle = -CGFloat.pi / 2 // Start at top
		
		for i in 0..<sides {
			let angle = startAngle + angleStep * CGFloat(i)
			let x = center.x + radius * cos(angle)
			let y = center.y + radius * sin(angle)
			
			if i == 0 {
				path.move(to: CGPoint(x: x, y: y))
			} else {
				path.addLine(to: CGPoint(x: x, y: y))
			}
		}
		
		path.closeSubpath()
		return path
	}
	
	/// Create straight line connector path
	private func createLineConnectorPath(in bounds: CGRect) -> CGPath {
		let path = CGMutablePath()
		
		// Draw a line from left to right center
		path.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
		path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
		
		return path
	}
	
	/// Create left arrow path
	private func createLeftArrowPath(in bounds: CGRect) -> CGPath {
		// Create a right arrow and flip it
		var transform = CGAffineTransform(scaleX: -1, y: 1).translatedBy(x: -bounds.width, y: 0)
		return ShapeRenderer.createArrowPath(in: bounds).copy(using: &transform) ?? CGMutablePath()
	}
	
	/// Create up arrow path
	private func createUpArrowPath(in bounds: CGRect) -> CGPath {
		// Create a right arrow and rotate it 90 degrees counter-clockwise
		var transform = CGAffineTransform(translationX: bounds.midX, y: bounds.midY)
			.rotated(by: -CGFloat.pi / 2)
			.translatedBy(x: -bounds.midX, y: -bounds.midY)
		return ShapeRenderer.createArrowPath(in: bounds).copy(using: &transform) ?? CGMutablePath()
	}
	
	/// Create down arrow path
	private func createDownArrowPath(in bounds: CGRect) -> CGPath {
		// Create a right arrow and rotate it 90 degrees clockwise
		var transform = CGAffineTransform(translationX: bounds.midX, y: bounds.midY)
			.rotated(by: CGFloat.pi / 2)
			.translatedBy(x: -bounds.midX, y: -bounds.midY)
		return ShapeRenderer.createArrowPath(in: bounds).copy(using: &transform) ?? CGMutablePath()
	}
	
	/// Create left-right arrow path
	private func createLeftRightArrowPath(in bounds: CGRect) -> CGPath {
		let path = CGMutablePath()
		
		let arrowHeadWidth = bounds.width * 0.2
		let shaftHeight = bounds.height * 0.6
		let shaftTop = (bounds.height - shaftHeight) / 2
		
		// Left arrow head
		path.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
		path.addLine(to: CGPoint(x: bounds.minX + arrowHeadWidth, y: bounds.minY))
		path.addLine(to: CGPoint(x: bounds.minX + arrowHeadWidth, y: bounds.minY + shaftTop))
		
		// Shaft top
		path.addLine(to: CGPoint(x: bounds.maxX - arrowHeadWidth, y: bounds.minY + shaftTop))
		
		// Right arrow head top
		path.addLine(to: CGPoint(x: bounds.maxX - arrowHeadWidth, y: bounds.minY))
		path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
		
		// Right arrow head bottom
		path.addLine(to: CGPoint(x: bounds.maxX - arrowHeadWidth, y: bounds.maxY))
		path.addLine(to: CGPoint(x: bounds.maxX - arrowHeadWidth, y: bounds.minY + shaftTop + shaftHeight))
		
		// Shaft bottom
		path.addLine(to: CGPoint(x: bounds.minX + arrowHeadWidth, y: bounds.minY + shaftTop + shaftHeight))
		
		// Left arrow head bottom
		path.addLine(to: CGPoint(x: bounds.minX + arrowHeadWidth, y: bounds.maxY))
		
		path.closeSubpath()
		return path
	}
	
	/// Create up-down arrow path
	private func createUpDownArrowPath(in bounds: CGRect) -> CGPath {
		// Create a left-right arrow and rotate it 90 degrees
		var transform = CGAffineTransform(translationX: bounds.midX, y: bounds.midY)
			.rotated(by: CGFloat.pi / 2)
			.translatedBy(x: -bounds.midX, y: -bounds.midY)
		return createLeftRightArrowPath(in: bounds).copy(using: &transform) ?? CGMutablePath()
	}
	
	/// Create simple elements as fallback
	private func createSimpleElements(from slide: Slide) -> [RenderElement] {
		var elements: [RenderElement] = []
		
		// Add title if present
		if let title = slide.title {
			let titleElement = RenderElement(
				type: .text,
				frame: CGRect(x: 50, y: 50, width: context.size.width - 100, height: 100),
				content: .text(title, TextStyle.title),
				transform: .identity
			)
			elements.append(titleElement)
		}
		
		// Add text content
		var yOffset: CGFloat = 150
		for text in slide.textContent {
			let textElement = RenderElement(
				type: .text,
				frame: CGRect(x: 50, y: yOffset, width: context.size.width - 100, height: 50),
				content: .text(text, TextStyle.body),
				transform: .identity
			)
			elements.append(textElement)
			yOffset += 60
		}
		
		return elements
	}
	
	/// Render elements to context
	private func renderElements(_ elements: [RenderElement], in context: CGContext) throws {
		for element in elements {
			context.saveGState()
			
			// Apply transform
			context.concatenate(element.transform)
			
			// Render based on type
			switch element.type {
			case .shape:
				try shapeRenderer.render(element, in: context)
			case .text:
				try textRenderer.render(element, in: context)
			case .image:
				try imageRenderer.render(element, in: context)
			case .group:
				if case .group(let children) = element.content {
					try renderElements(children, in: context)
				}
			}
			
			context.restoreGState()
		}
	}
}

/// Render element representation
public struct RenderElement {
	public enum ElementType {
		case shape
		case text
		case image
		case group
	}
	
	public enum Content {
		case shape(ShapeData)
		case text(String, TextStyle)
		case image(ImageData)
		case group([RenderElement])
	}
	
	public let type: ElementType
	public let frame: CGRect
	public let content: Content
	public let transform: CGAffineTransform
	
	public init(type: ElementType, frame: CGRect, content: Content, transform: CGAffineTransform = .identity) {
		self.type = type
		self.frame = frame
		self.content = content
		self.transform = transform
	}
}

/// Shape data for rendering
public struct ShapeData {
	public enum ShapeType {
		case rectangle
		case ellipse
		case custom(CGPath)
	}
	
	public let type: ShapeType
	public let fill: FillStyle?
	public let stroke: StrokeStyle?
	
	public init(type: ShapeType, fill: FillStyle? = nil, stroke: StrokeStyle? = nil) {
		self.type = type
		self.fill = fill
		self.stroke = stroke
	}
}

/// Text styling
public struct TextStyle {
	public let font: PlatformFont
	public let color: CGColor
	public let alignment: NSTextAlignment
	
	public static let title = TextStyle(
		font: PlatformFont.systemFont(ofSize: 36, weight: .bold),
		color: CGColor(red: 0, green: 0, blue: 0, alpha: 1),
		alignment: .center
	)
	
	public static let body = TextStyle(
		font: PlatformFont.systemFont(ofSize: 18),
		color: CGColor(red: 0, green: 0, blue: 0, alpha: 1),
		alignment: .left
	)
	
	public init(font: PlatformFont, color: CGColor, alignment: NSTextAlignment = .left) {
		self.font = font
		self.color = color
		self.alignment = alignment
	}
}

/// Image data for rendering
public struct ImageData {
	public let cgImage: CGImage?
	public let placeholder: String?
	
	public init(cgImage: CGImage? = nil, placeholder: String? = nil) {
		self.cgImage = cgImage
		self.placeholder = placeholder
	}
}

/// Fill styles
public enum FillStyle {
	case solid(CGColor)
	case gradient(GradientFill)
	case pattern(PatternFill)
}

/// Gradient fill
public struct GradientFill {
	public let colors: [CGColor]
	public let locations: [CGFloat]
	public let startPoint: CGPoint
	public let endPoint: CGPoint
	
	public init(colors: [CGColor], locations: [CGFloat], startPoint: CGPoint, endPoint: CGPoint) {
		self.colors = colors
		self.locations = locations
		self.startPoint = startPoint
		self.endPoint = endPoint
	}
}

/// Pattern fill
public struct PatternFill {
	public let image: CGImage
	public let tileSize: CGSize
	
	public init(image: CGImage, tileSize: CGSize) {
		self.image = image
		self.tileSize = tileSize
	}
}

/// Stroke style
public struct StrokeStyle {
	public let color: CGColor
	public let width: CGFloat
	public let dash: [CGFloat]?
	
	public init(color: CGColor, width: CGFloat = 1.0, dash: [CGFloat]? = nil) {
		self.color = color
		self.width = width
		self.dash = dash
	}
}

/// Rendering errors
public enum RenderingError: Error {
	case contextCreationFailed
	case imageCreationFailed
	case invalidSlideData
	case missingResource(String)
}

// MARK: - Platform compatibility

#if os(macOS)
public typealias PlatformFont = NSFont
#else
public typealias PlatformFont = UIFont
#endif
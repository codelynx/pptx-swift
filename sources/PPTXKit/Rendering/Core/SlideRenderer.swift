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
	
	public init(context: RenderingContext, archive: Archive? = nil) {
		self.context = context
		self.archive = archive
		self.shapeRenderer = ShapeRenderer(context: context)
		self.textRenderer = TextRenderer(context: context)
		self.imageRenderer = ImageRenderer(context: context)
	}
	
	/// Set the archive for loading resources
	public func setArchive(_ archive: Archive?) {
		self.archive = archive
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
		
		// Flip coordinate system for macOS (origin at top-left)
		#if os(macOS)
		cgContext.translateBy(x: 0, y: CGFloat(pixelHeight))
		cgContext.scaleBy(x: 1, y: -1)
		#endif
		
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
			// Parse the slide XML to get detailed layout information
			let parser = SlideXMLParser()
			let shapes = try parser.parseSlide(data: xmlData)
			
			// Convert parsed shapes to render elements
			for shape in shapes {
				switch shape.type {
				case .textBox(let textBox):
					// Create text elements from the text box
					let textElements = createTextElements(from: textBox, frame: shape.frame, transform: shape.transform)
					elements.append(contentsOf: textElements)
					
				case .picture(let picture):
					// Try to load the actual image
					var imageData: ImageData
					
					print("[SlideRenderer] Processing picture with relId: \(picture.imageRelId)")
					print("[SlideRenderer] Available relationships: \(slide.relationships.map { $0.id })")
					
					// Find the relationship for this image
					if let relationship = slide.relationships.first(where: { $0.id == picture.imageRelId }) {
						print("[SlideRenderer] Found relationship - target: \(relationship.target), type: \(relationship.type)")
						
						// Try to load the image from archive
						if let archive = archive {
							print("[SlideRenderer] Archive available, attempting to load image")
							do {
								if let cgImage = try imageRenderer.loadImageSync(from: relationship, in: archive) {
									print("[SlideRenderer] Successfully loaded image")
									imageData = ImageData(cgImage: cgImage)
								} else {
									print("[SlideRenderer] Failed to load image from: \(relationship.target)")
									imageData = ImageData(placeholder: "Failed to load: \(relationship.target)")
								}
							} catch {
								print("[SlideRenderer] Error loading image: \(error)")
								// Fall back to placeholder on error
								imageData = ImageData(placeholder: "Error loading: \(relationship.target)")
							}
						} else {
							print("[SlideRenderer] No archive available for image loading")
							imageData = ImageData(placeholder: "No archive: \(picture.imageRelId)")
						}
					} else {
						print("[SlideRenderer] Relationship not found for relId: \(picture.imageRelId)")
						imageData = ImageData(placeholder: "Missing relationship: \(picture.imageRelId)")
					}
					
					let imageElement = RenderElement(
						type: .image,
						frame: shape.frame,
						content: .image(imageData),
						transform: shape.transform
					)
					elements.append(imageElement)
					
				case .shape(let shapeData):
					// Create shape element
					let shapeElement = createShapeElement(
						from: shapeData,
						frame: shape.frame,
						transform: shape.transform
					)
					elements.append(shapeElement)
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
				let textHeight = lineHeight * CGFloat(paragraphText.components(separatedBy: .newlines).count)
				
				// Create render element
				let element = RenderElement(
					type: .text,
					frame: CGRect(
						x: frame.origin.x + textBox.bodyProperties.margins.left + paragraph.properties.indent,
						y: yOffset,
						width: frame.width - textBox.bodyProperties.margins.left - textBox.bodyProperties.margins.right - paragraph.properties.indent,
						height: textHeight
					),
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
	private func createShapeElement(from shapeData: SlideXMLParser.ShapeData, frame: CGRect, transform: CGAffineTransform) -> RenderElement {
		// Determine shape type
		let shapeType: ShapeData.ShapeType
		switch shapeData.type {
		case "rect", "rectangle":
			shapeType = .rectangle
		case "ellipse", "circle":
			shapeType = .ellipse
		default:
			// Default to rectangle for unknown shapes
			shapeType = .rectangle
		}
		
		// Create fill style
		let fillStyle: FillStyle? = shapeData.fillColor.flatMap { colorHex in
			parseHexColor(colorHex).map { FillStyle.solid($0) }
		}
		
		// Create stroke style
		let strokeStyle: StrokeStyle? = shapeData.strokeColor.flatMap { colorHex in
			parseHexColor(colorHex).map { color in
				StrokeStyle(color: color, width: shapeData.strokeWidth ?? 1.0)
			}
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
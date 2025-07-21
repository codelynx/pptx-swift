import Foundation
import CoreGraphics
import CoreText
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Renderer for text elements
public class TextRenderer {
	private let context: RenderingContext
	private let fontMapper: FontMapper
	
	public init(context: RenderingContext) {
		self.context = context
		self.fontMapper = FontMapper()
	}
	
	public func render(_ element: RenderElement, in cgContext: CGContext) throws {
		guard case .text(let string, let style) = element.content else {
			return
		}
		
		// Skip if text rendering is disabled
		guard context.options.renderText else {
			return
		}
		
		// Create attributed string
		let attributes = createAttributes(for: style)
		let attributedString = NSAttributedString(string: string, attributes: attributes)
		
		// Create framesetter
		let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
		
		// Create path for text frame
		let path = CGPath(rect: element.frame, transform: nil)
		
		// Create frame
		let ctFrame = CTFramesetterCreateFrame(
			framesetter,
			CFRange(location: 0, length: attributedString.length),
			path,
			nil
		)
		
		// Save context state
		cgContext.saveGState()
		
		// Flip coordinate system for text rendering
		#if os(macOS)
		// On macOS, we've already flipped the context in SlideRenderer, but Core Text needs another flip
		cgContext.translateBy(x: 0, y: element.frame.maxY)
		cgContext.scaleBy(x: 1, y: -1)
		cgContext.translateBy(x: 0, y: -element.frame.minY)
		#else
		// On iOS, flip for text rendering
		cgContext.translateBy(x: 0, y: element.frame.maxY)
		cgContext.scaleBy(x: 1, y: -1)
		cgContext.translateBy(x: 0, y: -element.frame.minY)
		#endif
		
		// Draw the frame
		CTFrameDraw(ctFrame, cgContext)
		
		// Restore context state
		cgContext.restoreGState()
	}
	
	private func createAttributes(for style: TextStyle) -> [NSAttributedString.Key: Any] {
		var attributes: [NSAttributedString.Key: Any] = [:]
		
		// Font
		let mappedFont = fontMapper.mapFont(style.font)
		let ctFont = CTFontCreateWithName(mappedFont.fontName as CFString, mappedFont.pointSize, nil)
		attributes[.font] = ctFont
		
		// Color
		attributes[.foregroundColor] = style.color
		
		// Paragraph style for alignment
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = style.alignment
		attributes[.paragraphStyle] = paragraphStyle
		
		return attributes
	}
}

/// Maps Windows/Office fonts to system fonts
public class FontMapper {
	private let fontMap: [String: String] = [
		// Common Office fonts to system fonts
		"Calibri": "Helvetica Neue",
		"Calibri Light": "Helvetica Neue Light",
		"Arial": "Helvetica",
		"Arial Black": "Helvetica Bold",
		"Times New Roman": "Times",
		"Comic Sans MS": "Marker Felt",
		"Courier New": "Courier",
		"Georgia": "Georgia",
		"Tahoma": "Helvetica",
		"Trebuchet MS": "Trebuchet MS",
		"Verdana": "Verdana",
		"Impact": "Impact",
		"Lucida Console": "Monaco",
		"Lucida Sans": "Lucida Grande",
		"Palatino Linotype": "Palatino",
		"Segoe UI": "Helvetica Neue",
		"Segoe UI Light": "Helvetica Neue UltraLight",
		"Segoe UI Semibold": "Helvetica Neue Medium",
		
		// Japanese fonts
		"MS Gothic": "Hiragino Kaku Gothic ProN",
		"MS PGothic": "Hiragino Kaku Gothic ProN",
		"MS Mincho": "Hiragino Mincho ProN",
		"MS PMincho": "Hiragino Mincho ProN",
		"Meiryo": "Hiragino Sans",
		"Meiryo UI": "Hiragino Sans",
		"Yu Gothic": "Hiragino Sans",
		"Yu Gothic UI": "Hiragino Sans",
		"Yu Mincho": "Hiragino Mincho ProN",
		"メイリオ": "Hiragino Sans",
		"游ゴシック": "Hiragino Sans",
		"游明朝": "Hiragino Mincho ProN",
		"ＭＳ ゴシック": "Hiragino Kaku Gothic ProN",
		"ＭＳ 明朝": "Hiragino Mincho ProN"
	]
	
	public func mapFont(_ font: PlatformFont) -> PlatformFont {
		let fontName = font.fontName
		
		// Check if we have a mapping
		if let mappedName = fontMap[fontName] {
			if let mappedFont = PlatformFont(name: mappedName, size: font.pointSize) {
				return mappedFont
			}
		}
		
		// Try to find a close match based on traits
		return findBestMatch(for: font) ?? font
	}
	
	private func findBestMatch(for font: PlatformFont) -> PlatformFont? {
		let descriptor = font.fontDescriptor
		let traits = descriptor.symbolicTraits
		
		#if os(macOS)
		let isBold = traits.contains(.bold)
		let isItalic = traits.contains(.italic)
		let isMonospace = traits.contains(.monoSpace)
		#else
		let isBold = traits.contains(.traitBold)
		let isItalic = traits.contains(.traitItalic)
		let isMonospace = traits.contains(.traitMonoSpace)
		#endif
		
		// Determine font family based on traits
		let familyName: String
		if isMonospace {
			familyName = "Menlo"
		} else {
			let fontFamily = font.familyName ?? ""
			
			if fontFamily.lowercased().contains("serif") {
				familyName = "Times"
			} else {
				familyName = "Helvetica Neue"
			}
		}
		
		// Build font with traits
		var fontTraits: [String] = []
		if isBold { fontTraits.append("Bold") }
		if isItalic { fontTraits.append("Italic") }
		
		let fontFullName = fontTraits.isEmpty ? familyName : "\(familyName) \(fontTraits.joined(separator: " "))"
		
		return PlatformFont(name: fontFullName, size: font.pointSize)
	}
	
	public func mapFontName(_ name: String) -> String {
		return fontMap[name] ?? name
	}
}

// MARK: - Rich Text Support

extension TextRenderer {
	/// Render rich text with multiple styles
	public func renderRichText(_ richText: [RichTextRun], in frame: CGRect, context: CGContext) {
		let attributedString = NSMutableAttributedString()
		
		for run in richText {
			let attributes = createAttributes(for: run.style)
			let runString = NSAttributedString(string: run.text, attributes: attributes)
			attributedString.append(runString)
		}
		
		// Create framesetter and render
		let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
		let path = CGPath(rect: frame, transform: nil)
		let ctFrame = CTFramesetterCreateFrame(
			framesetter,
			CFRange(location: 0, length: attributedString.length),
			path,
			nil
		)
		
		context.saveGState()
		
		#if os(macOS)
		// On macOS, we've already flipped the context in SlideRenderer, so no need to flip again
		#else
		// On iOS, flip for text rendering
		context.translateBy(x: 0, y: frame.maxY)
		context.scaleBy(x: 1, y: -1)
		context.translateBy(x: 0, y: -frame.minY)
		#endif
		
		CTFrameDraw(ctFrame, context)
		
		context.restoreGState()
	}
}

/// Rich text run with style
public struct RichTextRun {
	public let text: String
	public let style: TextStyle
	
	public init(text: String, style: TextStyle) {
		self.text = text
		self.style = style
	}
}
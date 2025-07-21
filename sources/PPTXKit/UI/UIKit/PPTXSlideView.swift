import Foundation
import CoreGraphics

#if canImport(UIKit)
import UIKit

/// UIKit implementation of PPTX slide view
public class PPTXSlideView: UIView {
	private var slide: Slide?
	private var document: PPTXDocument?
	private var slideIndex: Int?
	private var slideId: String?
	
	private var renderer: SlideRenderer?
	private var renderedImage: UIImage?
	private var lastError: Error?
	
	/// Error handler callback
	public var errorHandler: ((Error) -> Void)?
	
	/// Rendering scale factor
	public var renderingScale: CGFloat = UIScreen.main.scale {
		didSet { setNeedsRender() }
	}
	
	/// Background color
	public override var backgroundColor: UIColor? {
		didSet { setNeedsDisplay() }
	}
	
	/// Rendering quality
	public var renderingQuality: RenderingQuality = .balanced {
		didSet { setNeedsRender() }
	}
	
	/// Whether to show error placeholder when rendering fails
	public var showErrorPlaceholder: Bool = true
	
	/// Initialize with a slide
	public init(slide: Slide, frame: CGRect) {
		self.slide = slide
		super.init(frame: frame)
		setupView()
	}
	
	/// Initialize with document and slide index
	public init(document: PPTXDocument, slideIndex: Int, frame: CGRect = .zero) {
		self.document = document
		self.slideIndex = slideIndex
		super.init(frame: frame)
		setupView()
	}
	
	/// Initialize with document and slide ID
	public init(document: PPTXDocument, slideId: String, frame: CGRect = .zero) {
		self.document = document
		self.slideId = slideId
		super.init(frame: frame)
		setupView()
	}
	
	/// Initialize empty view
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
	}
	
	private func setupView() {
		backgroundColor = .white
		contentMode = .scaleAspectFit
		
		// Trigger initial render
		setNeedsRender()
	}
	
	/// Mark view for re-rendering
	public func setNeedsRender() {
		renderedImage = nil
		setNeedsDisplay()
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		setNeedsRender()
	}
	
	public override func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }
		
		// Draw background
		if let bgColor = backgroundColor {
			context.setFillColor(bgColor.cgColor)
			context.fill(rect)
		}
		
		// Get or render image
		if renderedImage == nil {
			renderSlide()
		}
		
		// Draw rendered image
		if let image = renderedImage {
			let imageRect = calculateImageRect(for: image.size, in: bounds)
			image.draw(in: imageRect)
		}
	}
	
	private func renderSlide() {
		// Load slide if needed
		if slide == nil {
			loadSlide()
		}
		
		guard let slide = slide else {
			if showErrorPlaceholder {
				renderErrorPlaceholder(PPTXDocument.PPTXError.slideNotFound)
			}
			return
		}
		
		// Create rendering context
		let renderContext = RenderingContext(
			size: bounds.size,
			scale: renderingScale,
			quality: renderingQuality
		)
		
		// Create renderer
		let renderer = SlideRenderer(context: renderContext)
		
		// Render slide
		do {
			// Pass archive if we have access to the document
			let archive = document?.archive
			let cgImage = try renderer.render(slide: slide, archive: archive)
			renderedImage = UIImage(cgImage: cgImage)
			lastError = nil
		} catch {
			lastError = error
			errorHandler?(error)
			if showErrorPlaceholder {
				renderErrorPlaceholder(error)
			}
		}
	}
	
	private func loadSlide() {
		guard let document = document else {
			let error = PPTXDocument.PPTXError.documentNotSet
			lastError = error
			errorHandler?(error)
			return
		}
		
		do {
			if let index = slideIndex {
				slide = try document.getSlide(at: index)
			} else if let id = slideId {
				slide = try document.getSlide(withId: id)
			}
			lastError = nil
		} catch {
			lastError = error
			errorHandler?(error)
			if showErrorPlaceholder {
				renderErrorPlaceholder(error)
			}
		}
	}
	
	private func calculateImageRect(for imageSize: CGSize, in bounds: CGRect) -> CGRect {
		let imageAspect = imageSize.width / imageSize.height
		let boundsAspect = bounds.width / bounds.height
		
		if imageAspect > boundsAspect {
			// Image is wider
			let height = bounds.width / imageAspect
			let y = (bounds.height - height) / 2
			return CGRect(x: 0, y: y, width: bounds.width, height: height)
		} else {
			// Image is taller
			let width = bounds.height * imageAspect
			let x = (bounds.width - width) / 2
			return CGRect(x: x, y: 0, width: width, height: bounds.height)
		}
	}
	
	private func renderErrorPlaceholder(_ error: Error) {
		let renderer = UIGraphicsImageRenderer(size: bounds.size)
		renderedImage = renderer.image { context in
			let rect = CGRect(origin: .zero, size: bounds.size)
			
			// Background
			UIColor.systemGray5.setFill()
			context.fill(rect)
			
			// Border
			UIColor.systemRed.setStroke()
			let borderPath = UIBezierPath(rect: rect.insetBy(dx: 2, dy: 2))
			borderPath.lineWidth = 2
			borderPath.stroke()
			
			// Error icon
			let iconSize: CGFloat = 48
			let iconRect = CGRect(x: (bounds.width - iconSize) / 2,
								  y: (bounds.height - iconSize) / 2 - 20,
								  width: iconSize,
								  height: iconSize)
			
			if let exclamationImage = UIImage(systemName: "exclamationmark.triangle.fill") {
				UIColor.systemRed.setFill()
				exclamationImage.draw(in: iconRect)
			}
			
			// Error text
			let errorText = "Rendering Error"
			let attributes: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: 16, weight: .medium),
				.foregroundColor: UIColor.systemRed
			]
			
			let textSize = errorText.size(withAttributes: attributes)
			let textRect = CGRect(x: (bounds.width - textSize.width) / 2,
								  y: iconRect.maxY + 10,
								  width: textSize.width,
								  height: textSize.height)
			
			errorText.draw(in: textRect, withAttributes: attributes)
			
			// Error description
			let description = error.localizedDescription
			let descAttributes: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: 12),
				.foregroundColor: UIColor.secondaryLabel
			]
			
			let descSize = description.boundingRect(
				with: CGSize(width: bounds.width - 40, height: .greatestFiniteMagnitude),
				options: [.usesLineFragmentOrigin, .usesFontLeading],
				attributes: descAttributes,
				context: nil
			).size
			
			let descRect = CGRect(x: (bounds.width - descSize.width) / 2,
								  y: textRect.maxY + 5,
								  width: descSize.width,
								  height: descSize.height)
			
			description.draw(in: descRect, withAttributes: descAttributes)
		}
	}
	
	/// Get the last error that occurred during rendering
	public var renderingError: Error? {
		return lastError
	}
	
	/// Render to image
	public func renderToImage() -> UIImage? {
		let renderer = UIGraphicsImageRenderer(size: bounds.size)
		return renderer.image { context in
			layer.render(in: context.cgContext)
		}
	}
}

#elseif canImport(AppKit)
import AppKit

/// AppKit implementation of PPTX slide view
public class PPTXSlideView: NSView {
	private var slide: Slide?
	private var document: PPTXDocument?
	private var slideIndex: Int?
	private var slideId: String?
	
	private var renderer: SlideRenderer?
	private var renderedImage: NSImage?
	private var lastError: Error?
	
	/// Error handler callback
	public var errorHandler: ((Error) -> Void)?
	
	/// Rendering scale factor
	public var renderingScale: CGFloat = 2.0 {
		didSet { setNeedsRender() }
	}
	
	/// Rendering quality
	public var renderingQuality: RenderingQuality = .balanced {
		didSet { setNeedsRender() }
	}
	
	/// Whether to show error placeholder when rendering fails
	public var showErrorPlaceholder: Bool = true
	
	/// Initialize with a slide
	public init(slide: Slide, frame: CGRect) {
		self.slide = slide
		super.init(frame: frame)
		setupView()
	}
	
	/// Initialize with document and slide index
	public init(document: PPTXDocument, slideIndex: Int, frame: CGRect = .zero) {
		self.document = document
		self.slideIndex = slideIndex
		super.init(frame: frame)
		setupView()
	}
	
	/// Initialize with document and slide ID
	public init(document: PPTXDocument, slideId: String, frame: CGRect = .zero) {
		self.document = document
		self.slideId = slideId
		super.init(frame: frame)
		setupView()
	}
	
	/// Initialize empty view
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
	}
	
	private func setupView() {
		wantsLayer = true
		layer?.backgroundColor = NSColor.white.cgColor
		
		// Trigger initial render
		setNeedsRender()
	}
	
	/// Mark view for re-rendering
	public func setNeedsRender() {
		renderedImage = nil
		needsDisplay = true
	}
	
	public override func layout() {
		super.layout()
		setNeedsRender()
	}
	
	public override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		guard let context = NSGraphicsContext.current?.cgContext else { return }
		
		// Draw background
		if let bgColor = layer?.backgroundColor {
			context.setFillColor(bgColor)
			context.fill(dirtyRect)
		}
		
		// Get or render image
		if renderedImage == nil {
			renderSlide()
		}
		
		// Draw rendered image
		if let image = renderedImage {
			let imageRect = calculateImageRect(for: image.size, in: bounds)
			image.draw(in: imageRect)
		}
	}
	
	private func renderSlide() {
		// Load slide if needed
		if slide == nil {
			loadSlide()
		}
		
		guard let slide = slide else {
			if showErrorPlaceholder {
				renderErrorPlaceholder(PPTXDocument.PPTXError.slideNotFound)
			}
			return
		}
		
		// Create rendering context
		let renderContext = RenderingContext(
			size: bounds.size,
			scale: renderingScale,
			quality: renderingQuality
		)
		
		// Create renderer
		let renderer = SlideRenderer(context: renderContext)
		
		// Render slide
		do {
			// Pass archive if we have access to the document
			let archive = document?.archive
			let cgImage = try renderer.render(slide: slide, archive: archive)
			renderedImage = NSImage(cgImage: cgImage, size: bounds.size)
			lastError = nil
		} catch {
			lastError = error
			errorHandler?(error)
			if showErrorPlaceholder {
				renderErrorPlaceholder(error)
			}
		}
	}
	
	private func loadSlide() {
		guard let document = document else {
			let error = PPTXDocument.PPTXError.documentNotSet
			lastError = error
			errorHandler?(error)
			return
		}
		
		do {
			if let index = slideIndex {
				slide = try document.getSlide(at: index)
			} else if let id = slideId {
				slide = try document.getSlide(withId: id)
			}
			lastError = nil
		} catch {
			lastError = error
			errorHandler?(error)
			if showErrorPlaceholder {
				renderErrorPlaceholder(error)
			}
		}
	}
	
	private func calculateImageRect(for imageSize: CGSize, in bounds: CGRect) -> CGRect {
		let imageAspect = imageSize.width / imageSize.height
		let boundsAspect = bounds.width / bounds.height
		
		if imageAspect > boundsAspect {
			// Image is wider
			let height = bounds.width / imageAspect
			let y = (bounds.height - height) / 2
			return CGRect(x: 0, y: y, width: bounds.width, height: height)
		} else {
			// Image is taller
			let width = bounds.height * imageAspect
			let x = (bounds.width - width) / 2
			return CGRect(x: x, y: 0, width: width, height: bounds.height)
		}
	}
	
	private func renderErrorPlaceholder(_ error: Error) {
		let image = NSImage(size: bounds.size)
		image.lockFocus()
		
		// Background
		NSColor.controlBackgroundColor.setFill()
		NSBezierPath.fill(bounds)
		
		// Border
		NSColor.systemRed.setStroke()
		let borderPath = NSBezierPath(rect: bounds.insetBy(dx: 2, dy: 2))
		borderPath.lineWidth = 2
		borderPath.stroke()
		
		// Error icon
		let iconSize: CGFloat = 48
		let iconRect = NSRect(x: (bounds.width - iconSize) / 2,
							  y: (bounds.height - iconSize) / 2 + 20,
							  width: iconSize,
							  height: iconSize)
		
		if let exclamationImage = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: nil) {
			exclamationImage.draw(in: iconRect)
		}
		
		// Error text
		let errorText = "Rendering Error"
		let attributes: [NSAttributedString.Key: Any] = [
			.font: NSFont.systemFont(ofSize: 16, weight: .medium),
			.foregroundColor: NSColor.systemRed
		]
		
		let textSize = errorText.size(withAttributes: attributes)
		let textRect = NSRect(x: (bounds.width - textSize.width) / 2,
							  y: iconRect.minY - textSize.height - 10,
							  width: textSize.width,
							  height: textSize.height)
		
		errorText.draw(in: textRect, withAttributes: attributes)
		
		// Error description
		let description = error.localizedDescription
		let descAttributes: [NSAttributedString.Key: Any] = [
			.font: NSFont.systemFont(ofSize: 12),
			.foregroundColor: NSColor.secondaryLabelColor
		]
		
		let descSize = description.boundingRect(
			with: NSSize(width: bounds.width - 40, height: .greatestFiniteMagnitude),
			options: [.usesLineFragmentOrigin, .usesFontLeading],
			attributes: descAttributes
		).size
		
		let descRect = NSRect(x: (bounds.width - descSize.width) / 2,
							  y: textRect.minY - descSize.height - 5,
							  width: descSize.width,
							  height: descSize.height)
		
		description.draw(in: descRect, withAttributes: descAttributes)
		
		image.unlockFocus()
		renderedImage = image
	}
	
	/// Get the last error that occurred during rendering
	public var renderingError: Error? {
		return lastError
	}
	
	/// Render to image
	public func renderToImage() -> NSImage? {
		let image = NSImage(size: bounds.size)
		image.lockFocus()
		
		if let context = NSGraphicsContext.current?.cgContext {
			layer?.render(in: context)
		}
		
		image.unlockFocus()
		return image
	}
}
#endif
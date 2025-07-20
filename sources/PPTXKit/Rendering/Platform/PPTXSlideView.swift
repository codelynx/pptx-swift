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
        
        guard let slide = slide else { return }
        
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
            let cgImage = try renderer.render(slide: slide)
            renderedImage = UIImage(cgImage: cgImage)
        } catch {
            print("Rendering error: \(error)")
            // Could show error placeholder here
        }
    }
    
    private func loadSlide() {
        guard let document = document else { return }
        
        do {
            if let index = slideIndex {
                slide = try document.getSlide(at: index)
            } else if let id = slideId {
                slide = try document.getSlide(withId: id)
            }
        } catch {
            print("Failed to load slide: \(error)")
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
    
    /// Rendering scale factor
    public var renderingScale: CGFloat = 2.0 {
        didSet { setNeedsRender() }
    }
    
    /// Rendering quality
    public var renderingQuality: RenderingQuality = .balanced {
        didSet { setNeedsRender() }
    }
    
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
        
        guard let slide = slide else { return }
        
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
            let cgImage = try renderer.render(slide: slide)
            renderedImage = NSImage(cgImage: cgImage, size: bounds.size)
        } catch {
            print("Rendering error: \(error)")
            // Could show error placeholder here
        }
    }
    
    private func loadSlide() {
        guard let document = document else { return }
        
        do {
            if let index = slideIndex {
                slide = try document.getSlide(at: index)
            } else if let id = slideId {
                slide = try document.getSlide(withId: id)
            }
        } catch {
            print("Failed to load slide: \(error)")
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
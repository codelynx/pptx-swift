import Foundation
import CoreGraphics
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
    
    public init(context: RenderingContext) {
        self.context = context
        self.shapeRenderer = ShapeRenderer(context: context)
        self.textRenderer = TextRenderer(context: context)
        self.imageRenderer = ImageRenderer(context: context)
    }
    
    /// Render a slide to a CGImage
    public func render(slide: Slide) throws -> CGImage {
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
        
        // Apply scale for retina
        cgContext.scaleBy(x: context.scale, y: context.scale)
        
        // Render background
        if context.options.renderBackground {
            renderBackground(in: cgContext)
        }
        
        // Parse and render slide content
        let renderTree = try buildRenderTree(from: slide)
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
    private func buildRenderTree(from slide: Slide) throws -> [RenderElement] {
        var elements: [RenderElement] = []
        
        // TODO: Parse slide XML to extract shapes, text, images
        // For now, create demo elements based on slide properties
        
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
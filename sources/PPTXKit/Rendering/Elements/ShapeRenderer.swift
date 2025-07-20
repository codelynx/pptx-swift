import Foundation
import CoreGraphics

/// Renderer for shape elements
public class ShapeRenderer {
    private let context: RenderingContext
    
    public init(context: RenderingContext) {
        self.context = context
    }
    
    public func render(_ element: RenderElement, in cgContext: CGContext) throws {
        guard case .shape(let shapeData) = element.content else {
            return
        }
        
        // Create path based on shape type
        let path = createPath(for: shapeData.type, in: element.frame)
        
        // Apply fill
        if let fill = shapeData.fill {
            applyFill(fill, to: path, in: cgContext)
        }
        
        // Apply stroke
        if let stroke = shapeData.stroke {
            applyStroke(stroke, to: path, in: cgContext)
        }
    }
    
    private func createPath(for shapeType: ShapeData.ShapeType, in frame: CGRect) -> CGPath {
        switch shapeType {
        case .rectangle:
            return CGPath(rect: frame, transform: nil)
            
        case .ellipse:
            return CGPath(ellipseIn: frame, transform: nil)
            
        case .custom(let path):
            return path
        }
    }
    
    private func applyFill(_ fill: FillStyle, to path: CGPath, in context: CGContext) {
        context.saveGState()
        
        switch fill {
        case .solid(let color):
            context.setFillColor(color)
            context.addPath(path)
            context.fillPath()
            
        case .gradient(let gradient):
            if self.context.quality.rendersGradients {
                applyGradientFill(gradient, to: path, in: context)
            } else {
                // Fallback to first color for low quality
                context.setFillColor(gradient.colors.first ?? CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1))
                context.addPath(path)
                context.fillPath()
            }
            
        case .pattern(let pattern):
            applyPatternFill(pattern, to: path, in: context)
        }
        
        context.restoreGState()
    }
    
    private func applyGradientFill(_ gradient: GradientFill, to path: CGPath, in context: CGContext) {
        context.saveGState()
        context.addPath(path)
        context.clip()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let cgGradient = CGGradient(
            colorsSpace: colorSpace,
            colors: gradient.colors as CFArray,
            locations: gradient.locations
        ) else {
            context.restoreGState()
            return
        }
        
        let bounds = path.boundingBox
        let startPoint = CGPoint(
            x: bounds.minX + gradient.startPoint.x * bounds.width,
            y: bounds.minY + gradient.startPoint.y * bounds.height
        )
        let endPoint = CGPoint(
            x: bounds.minX + gradient.endPoint.x * bounds.width,
            y: bounds.minY + gradient.endPoint.y * bounds.height
        )
        
        context.drawLinearGradient(
            cgGradient,
            start: startPoint,
            end: endPoint,
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
        )
        
        context.restoreGState()
    }
    
    private func applyPatternFill(_ pattern: PatternFill, to path: CGPath, in context: CGContext) {
        // TODO: Implement pattern fill
        // For now, just fill with gray
        context.setFillColor(CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1))
        context.addPath(path)
        context.fillPath()
    }
    
    private func applyStroke(_ stroke: StrokeStyle, to path: CGPath, in context: CGContext) {
        context.saveGState()
        
        context.setStrokeColor(stroke.color)
        context.setLineWidth(stroke.width)
        
        if let dash = stroke.dash {
            context.setLineDash(phase: 0, lengths: dash)
        }
        
        context.addPath(path)
        context.strokePath()
        
        context.restoreGState()
    }
}

// MARK: - Preset Shape Paths

extension ShapeRenderer {
    /// Create path for arrow shape
    public static func createArrowPath(in bounds: CGRect) -> CGPath {
        let path = CGMutablePath()
        
        let arrowHeadWidth = bounds.width * 0.3
        let shaftHeight = bounds.height * 0.6
        let shaftTop = (bounds.height - shaftHeight) / 2
        
        // Shaft
        path.move(to: CGPoint(x: bounds.minX, y: bounds.minY + shaftTop))
        path.addLine(to: CGPoint(x: bounds.maxX - arrowHeadWidth, y: bounds.minY + shaftTop))
        
        // Arrow head top
        path.addLine(to: CGPoint(x: bounds.maxX - arrowHeadWidth, y: bounds.minY))
        
        // Arrow point
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
        
        // Arrow head bottom
        path.addLine(to: CGPoint(x: bounds.maxX - arrowHeadWidth, y: bounds.maxY))
        
        // Shaft bottom
        path.addLine(to: CGPoint(x: bounds.maxX - arrowHeadWidth, y: bounds.minY + shaftTop + shaftHeight))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + shaftTop + shaftHeight))
        
        path.closeSubpath()
        
        return path
    }
    
    /// Create path for star shape
    public static func createStarPath(points: Int = 5, in bounds: CGRect) -> CGPath {
        let path = CGMutablePath()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let outerRadius = min(bounds.width, bounds.height) / 2
        let innerRadius = outerRadius * 0.4
        
        let angleStep = (2 * CGFloat.pi) / CGFloat(points * 2)
        var angle = -CGFloat.pi / 2 // Start at top
        
        for i in 0..<(points * 2) {
            let radius = (i % 2 == 0) ? outerRadius : innerRadius
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            angle += angleStep
        }
        
        path.closeSubpath()
        
        return path
    }
    
    /// Create path for rounded rectangle
    public static func createRoundedRectPath(cornerRadius: CGFloat, in bounds: CGRect) -> CGPath {
        return CGPath(roundedRect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    }
}
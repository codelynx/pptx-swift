import Foundation
import CoreGraphics
import ZIPFoundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Renderer for image elements
public class ImageRenderer {
    private let context: RenderingContext
    
    public init(context: RenderingContext) {
        self.context = context
    }
    
    public func render(_ element: RenderElement, in cgContext: CGContext) throws {
        guard case .image(let imageData) = element.content else {
            return
        }
        
        // Skip if image rendering is disabled
        guard context.options.renderImages else {
            return
        }
        
        if let cgImage = imageData.cgImage {
            // Render the image
            renderImage(cgImage, in: element.frame, context: cgContext)
        } else if context.options.renderPlaceholders, let placeholder = imageData.placeholder {
            // Render placeholder
            renderPlaceholder(text: placeholder, in: element.frame, context: cgContext)
        }
    }
    
    private func renderImage(_ image: CGImage, in frame: CGRect, context: CGContext) {
        context.saveGState()
        
        // Calculate aspect-fit frame
        let imageAspect = CGFloat(image.width) / CGFloat(image.height)
        let frameAspect = frame.width / frame.height
        
        let drawRect: CGRect
        if imageAspect > frameAspect {
            // Image is wider than frame
            let height = frame.width / imageAspect
            let y = frame.origin.y + (frame.height - height) / 2
            drawRect = CGRect(x: frame.origin.x, y: y, width: frame.width, height: height)
        } else {
            // Image is taller than frame
            let width = frame.height * imageAspect
            let x = frame.origin.x + (frame.width - width) / 2
            drawRect = CGRect(x: x, y: frame.origin.y, width: width, height: frame.height)
        }
        
        // Flip the coordinate system for the image
        // Move to the bottom of the image rect
        context.translateBy(x: 0, y: drawRect.origin.y + drawRect.height)
        // Flip vertically
        context.scaleBy(x: 1, y: -1)
        // Move back
        context.translateBy(x: 0, y: -drawRect.origin.y)
        
        // Draw image
        context.draw(image, in: drawRect)
        
        context.restoreGState()
    }
    
    private func renderPlaceholder(text: String, in frame: CGRect, context: CGContext) {
        context.saveGState()
        
        // Draw placeholder background
        context.setFillColor(CGColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1))
        context.fill(frame)
        
        // Draw border
        context.setStrokeColor(CGColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1))
        context.setLineWidth(1)
        context.stroke(frame)
        
        // Draw diagonal lines
        context.setStrokeColor(CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1))
        context.move(to: CGPoint(x: frame.minX, y: frame.minY))
        context.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
        context.move(to: CGPoint(x: frame.maxX, y: frame.minY))
        context.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
        context.strokePath()
        
        // Draw placeholder text
        let style = TextStyle(
            font: PlatformFont.systemFont(ofSize: 14),
            color: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),
            alignment: .center
        )
        
        let textRenderer = TextRenderer(context: self.context)
        let textElement = RenderElement(
            type: .text,
            frame: frame.insetBy(dx: 10, dy: 10),
            content: .text(text, style),
            transform: .identity
        )
        
        try? textRenderer.render(textElement, in: context)
        
        context.restoreGState()
    }
}

// MARK: - Image Loading

extension ImageRenderer {
    /// Load image from slide relationship (synchronous version)
    public func loadImageSync(from relationship: Relationship, in archive: Archive?) throws -> CGImage? {
        guard let archive = archive else {
            throw RenderingError.missingResource("No archive provided")
        }
        
        print("[ImageRenderer] Loading image from relationship: \(relationship.target)")
        
        // Build the full path to the image in the archive
        // Handle relative paths in the relationship target
        let imagePath: String
        if relationship.target.hasPrefix("../") {
            // Remove ../ and construct path relative to ppt folder
            let relativePath = String(relationship.target.dropFirst(3))
            imagePath = "ppt/\(relativePath)"
            print("[ImageRenderer] Resolved relative path '../' to: \(imagePath)")
        } else if relationship.target.hasPrefix("/") {
            // Absolute path
            imagePath = String(relationship.target.dropFirst())
            print("[ImageRenderer] Using absolute path: \(imagePath)")
        } else {
            // Relative to slides folder
            imagePath = "ppt/slides/\(relationship.target)"
            print("[ImageRenderer] Resolved relative path to: \(imagePath)")
        }
        
        // Find the entry in the archive
        guard let entry = archive[imagePath] else {
            print("[ImageRenderer] Image not found in archive at path: \(imagePath)")
            print("[ImageRenderer] Available entries in archive:")
            // List some entries for debugging
            var count = 0
            for entry in archive {
                if entry.path.contains("media") || entry.path.contains("image") {
                    print("[ImageRenderer]   - \(entry.path)")
                    count += 1
                    if count > 10 { break }
                }
            }
            throw RenderingError.missingResource("Image not found: \(imagePath)")
        }
        
        // Extract the image data
        var imageData = Data()
        do {
            _ = try archive.extract(entry) { data in
                imageData.append(data)
            }
        } catch {
            throw RenderingError.missingResource("Failed to extract image: \(error)")
        }
        
        // Create CGImage from data
        #if canImport(UIKit)
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            throw RenderingError.missingResource("Failed to create image from data")
        }
        return cgImage
        #elseif canImport(AppKit)
        guard let nsImage = NSImage(data: imageData) else {
            throw RenderingError.missingResource("Failed to create NSImage from data")
        }
        
        // Convert NSImage to CGImage
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw RenderingError.missingResource("Failed to get CGImage from NSImage")
        }
        return cgImage
        #endif
    }
    
    /// Load image from slide relationship (async version)
    public func loadImage(from relationship: Relationship, in archive: Archive?) async throws -> CGImage? {
        guard let archive = archive else {
            throw RenderingError.missingResource("No archive provided")
        }
        
        // Build the full path to the image in the archive
        // Handle relative paths in the relationship target
        let imagePath: String
        if relationship.target.hasPrefix("../") {
            // Remove ../ and construct path relative to ppt folder
            let relativePath = String(relationship.target.dropFirst(3))
            imagePath = "ppt/\(relativePath)"
        } else if relationship.target.hasPrefix("/") {
            // Absolute path
            imagePath = String(relationship.target.dropFirst())
        } else {
            // Relative to slides folder
            imagePath = "ppt/slides/\(relationship.target)"
        }
        
        // Find the entry in the archive
        guard let entry = archive[imagePath] else {
            throw RenderingError.missingResource("Image not found: \(imagePath)")
        }
        
        // Extract the image data
        var imageData = Data()
        do {
            _ = try archive.extract(entry) { data in
                imageData.append(data)
            }
        } catch {
            throw RenderingError.missingResource("Failed to extract image: \(error)")
        }
        
        // Create CGImage from data
        #if canImport(UIKit)
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            throw RenderingError.missingResource("Failed to create image from data")
        }
        return cgImage
        #elseif canImport(AppKit)
        guard let nsImage = NSImage(data: imageData) else {
            throw RenderingError.missingResource("Failed to create NSImage from data")
        }
        
        // Convert NSImage to CGImage
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw RenderingError.missingResource("Failed to get CGImage from NSImage")
        }
        return cgImage
        #endif
    }
}

// MARK: - Image Effects

extension ImageRenderer {
    /// Apply image effects like cropping, filters
    public func applyEffects(to image: CGImage, effects: [ImageEffect]) -> CGImage? {
        var result = image
        
        for effect in effects {
            switch effect {
            case .crop(let rect):
                result = cropImage(result, to: rect) ?? result
            case .grayscale:
                result = applyGrayscale(to: result) ?? result
            case .brightness(let amount):
                result = adjustBrightness(of: result, by: amount) ?? result
            }
        }
        
        return result
    }
    
    private func cropImage(_ image: CGImage, to rect: CGRect) -> CGImage? {
        return image.cropping(to: rect)
    }
    
    private func applyGrayscale(to image: CGImage) -> CGImage? {
        // Create grayscale context
        let width = image.width
        let height = image.height
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return nil
        }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }
    
    private func adjustBrightness(of image: CGImage, by amount: CGFloat) -> CGImage? {
        // This would use Core Image filters in a full implementation
        return image
    }
}

/// Image effects that can be applied
public enum ImageEffect {
    case crop(CGRect)
    case grayscale
    case brightness(CGFloat)
}
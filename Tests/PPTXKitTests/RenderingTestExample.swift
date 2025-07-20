import XCTest
import PPTXKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import UniformTypeIdentifiers

/// Example test structure for slide rendering validation
final class RenderingTestExample: XCTestCase {
    
    /// Example of how we would test rendering once implemented
    func testRenderingComparison() throws {
        // This is a conceptual example - rendering not yet implemented
        
        // 1. Load PPTX document
        // let document = try PPTXDocument(filePath: "sample.pptx")
        
        // 2. Render slide (future implementation)
        // let slideView = PPTXSlideView(document: document, slideIndex: 1)
        // let renderedImage = slideView.renderToImage()
        
        // 3. Load reference image
        // let referenceImage = loadReferenceImage("slide-1.png")
        
        // 4. Compare images
        // let similarity = compareImages(renderedImage, referenceImage)
        // XCTAssertGreaterThan(similarity, 0.90, "Rendered image should match reference by at least 90%")
    }
    
    /// Example image comparison function
    func compareImages(_ image1: CGImage, _ image2: CGImage) -> Double {
        // Simple pixel-by-pixel comparison (naive approach)
        // In practice, we'd use perceptual comparison
        
        guard image1.width == image2.width,
              image1.height == image2.height else {
            return 0.0
        }
        
        // TODO: Implement actual comparison
        // Options:
        // 1. Use Vision framework for perceptual similarity
        // 2. Calculate SSIM (Structural Similarity Index)
        // 3. Use histogram comparison
        // 4. Pixel-by-pixel RMSE
        
        return 0.95 // Placeholder
    }
}

// MARK: - Test Helpers

extension XCTestCase {
    /// Load reference image from test bundle
    func loadReferenceImage(_ name: String) -> CGImage? {
        guard let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: nil),
              let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            return nil
        }
        return image
    }
    
    /// Save image for manual inspection
    func saveImageForInspection(_ image: CGImage, name: String) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(name)
        
        if let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) {
            CGImageDestinationAddImage(destination, image, nil)
            CGImageDestinationFinalize(destination)
            print("Saved test image to: \(url.path)")
        }
    }
}

// MARK: - Platform Compatibility

#if os(macOS)
typealias PlatformImage = NSImage
extension NSImage {
    var cgImage: CGImage? {
        cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
}
#else
typealias PlatformImage = UIImage
#endif